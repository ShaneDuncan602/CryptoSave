use serde::Deserialize;
use std::{env, str::FromStr};

use web3::{
    contract::{Contract, Options},
    types::{Address, H160, H256, U256},
};
use web3_unit_converter::Unit;

use reqwest::{Client, Url};

static MAX_HISTORIC_ENTRIES: usize = 100;

#[tokio::main]
async fn main() {
    let mut interval_timer = tokio::time::interval(chrono::Duration::seconds(10).to_std().unwrap());
    let mut historic_prices: Vec<f64> = vec![];
    let mut last_ema = 0f64;

    loop {
        interval_timer.tick().await;
        let spot_price_response = get_spot_eth_price().await;
        println!("{:?}", &spot_price_response);
        if let Ok(value) = spot_price_response {
            println!("got price {}", &value.ethereum.usd);
            historic_prices.push(value.ethereum.usd);
            let eth_price_wei = f64_to_u256(value.ethereum.usd);
            let latest_dai_price = f64_to_u256(1f64);

            // Let's just keep the last MAX_HISTORIC_ENTRIES
            if historic_prices.len() > MAX_HISTORIC_ENTRIES {
                historic_prices.remove(0);
            }

            println!("Got {} prices already", historic_prices.len());
            if historic_prices.len() > 2 {
                last_ema = ema(&historic_prices, last_ema);
                historic_prices = historic_prices;
            }

            println!("last EMA: {}", &last_ema);

            if let Ok(eth) = eth_price_wei {
                if let Ok(dai) = latest_dai_price {
                    println!("eth = {0}, dai = {1}", &eth, &dai);
                    let action = if is_downtrend(&last_ema, historic_prices.last().unwrap()) { 0u8 } else { 1u8 };
                    if let Ok(hash) = poke(action, eth, dai).await {
                        println!("Hash of the poke {}", hash);
                    } else {
                        println!("the was an error poking the contract");
                    }
                }
            }
        }

    }
}

fn f64_to_u256(price: f64) -> Result<U256, Error> {
    let as_uint = (price * 10_000f64) as u64;
    Ok(U256::from_dec_str(&as_uint.to_string()).map_err(|e| Error::ConversionError("couldn't convert price to U256".to_string()))?)
}

fn is_downtrend(ema: &f64, last_eth_price: &f64) -> bool {
    ema < last_eth_price
}

fn ema(prices: &Vec<f64>, last_ema: f64) -> f64 {
    let most_recent_price = prices.last().unwrap();
    let smoothing_result = 2f64 / (prices.len() + 1) as f64;

    return (most_recent_price * smoothing_result) + (last_ema * (1f64 - smoothing_result));
}

fn sma(prices: &Vec<f64>) -> f64 {
    let mut sma = 0f64;
    let size = prices.len() as f64;
    for price in prices {
        sma += price;
    }

    sma / size
}

async fn get_spot_eth_price() -> Result<SpotPriceResponse, Error> {
    let url = Url::parse_with_params(
        "https://api.coingecko.com/api/v3/simple/price",
        &[("ids", "ethereum,dai"), ("vs_currencies", "usd")],
    )
    .map_err(|e| Error::ServerSideError(format!("couldn't parse spot price url")))?;

    let response = Client::builder()
        .build()
        .map_err(|e| Error::ServerSideError(format!("couldn't build http client")))?
        .get(url)
        .send()
        .await
        .map_err(|e| Error::ServerSideError(format!("couldn't get spot price response")))?
        .json::<SpotPriceResponse>()
        .await
        .map_err(|e| Error::ServerSideError(format!("couldn't deserialize json")))?;

    Ok(response)
}

async fn poke(action: u8, eth_price: U256, dai_price: U256) -> Result<H256, Error> {
    let pvk = env::var("PRIVATE_KEY")
        .map_err(|e| Error::ServerSideError("couldn't read PRIVATE_KEY".to_string()))?;
    let secret_key = H160::from_str(&pvk).unwrap();
    let rpc_url = env::var("RPC_ENDPOINT")
        .map_err(|e| Error::ServerSideError("couldn't read RPC_ENDPOINT".to_string()))?;
    let contract_address = env::var("CONTRACT_ADDRESS")
        .map_err(|e| Error::ServerSideError("couldn't read contract address".to_string()))?;

    let ws = web3::transports::WebSocket::new(&rpc_url)
        .await
        .map_err(|e| Error::ServerSideError(format!("Failed to create web socket connection")))?;
    let web3 = web3::Web3::new(ws);

    let contract_address = Address::from_str(&contract_address).unwrap();
    let contract = Contract::from_json(
        web3.eth(),
        contract_address,
        include_bytes!("crypto_save.json"),
    )
    .map_err(|e| Error::ServerSideError("couldn't create contract instance".to_string()))?;

    let result = contract
        .call(
            "poke",
            (action, eth_price, dai_price),
            secret_key,
            Options::default(),
        )
        .await
        .map_err(|e| Error::Web3Error(format!("{:?}", e)))?;

    Ok(result)
}

#[derive(Debug)]
enum Error {
    ServerSideError(String),
    Web3Error(String),
    ConversionError(String)
}

#[derive(Deserialize, Debug)]
struct SpotPriceResponse {
    ethereum: PriceData,
    dai: PriceData
}

#[derive(Deserialize, Debug)]
struct PriceData {
    usd: f64,
}
