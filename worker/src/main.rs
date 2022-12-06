use serde::Deserialize;
use std::{env, str::FromStr};

use web3::{
    contract::{Contract, Options},
    types::{Address, H160},
};

use reqwest::{Client, Url};

#[tokio::main]
async fn main() {
    let mut interval_timer = tokio::time::interval(chrono::Duration::minutes(15).to_std().unwrap());
    loop {
        interval_timer.tick().await;
        tokio::spawn(async {
            poke().await;
        });
    }
}

async fn get_spot_eth_price() -> Result<SpotPriceResponse, Error> {
    let url = Url::parse_with_params(
        "https://api.coingecko.com/api/v3/simple/price",
        &[("ids", "ethereum"), ("vs_currencies", "usd")],
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

async fn poke() -> Result<(), Error> {
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
        include_bytes!("contract_abi.json"),
    )
    .map_err(|e| Error::ServerSideError("couldn't create contract instance".to_string()))?;

    contract.call("poke_me", (), secret_key, Options::default());

    Ok(())
}

#[derive(Debug)]
enum Error {
    ServerSideError(String),
}

#[derive(Deserialize)]
struct SpotPriceResponse {
    ethereum: PriceData,
}

#[derive(Deserialize)]
struct PriceData {
    usd: f64,
}
