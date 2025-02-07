openapi: "3.0.0"

info:
  version: 1.7.9
  title: Coinpaprika API
  x-logo:
    url: "https://coinpaprika.com/assets/img/API_logo_coinpage_1.svg"
    backgroundColor: "#FAFAFA"
  description: |
    Coinpaprika API delivers precise & frequently updated market data from the world of crypto: coin prices, volumes, market caps, ATHs, return rates and more.

    # Introduction
    If you want to use the Coinpaprika API, you have two main options: you can choose the API Free plan, which has sufficient limits for hobby and non-commercial use, or get one of the paid plans, ideal for commercial or professional use. To decide which plan is the best for you, check the [Plans and Pricing comparison](https://coinpaprika.com/api).

    Depending on the selected plan, you should send requests to the appropriate base URL:

    | Plan       | Base URL                            |
    |------------|-------------------------------------|
    | Free       | https://api.coinpaprika.com/v1/     |
    | Starter    | https://api-pro.coinpaprika.com/v1/ |
    | Pro        | https://api-pro.coinpaprika.com/v1/ |
    | Business   | https://api-pro.coinpaprika.com/v1/ |
    | Enterprise | https://api-pro.coinpaprika.com/v1/ |

    # Authentication
    If you use the Free plan, you don't need to set up an API key for each request. For other plans it is required. You can generate the API key in the Developer Portal after signing in.

    To provide the API key in REST API calls, set the `Authorization` header:
    ```
    Authorization: <api-key>
    ```

    # Standards and conventions
    ## General
   
    * All endpoints return either a JSON object or array
    * All timestamp related fields are in seconds

    ## Errors
    * API errors are formatted as JSON:
    ```{"error": "<error message>"}```
    * The API uses standard HTTP status codes to indicate a request failure:
      * HTTP 4XX return codes are used for invalid requests - the issue is on the sender's side
      * HTTP 5XX return codes are used for internal errors - the issue is on the server's side

      | HTTP Status | Description |
      |---|---|
      | 400 Bad Request | The server could not process the request due to invalid request parameters or invalid format of the parameters. |
      | 402 Payment Required | The request could not be processed because of the user has an insufficient plan. If you want to be able to process this request, get a [higher plan](https://coinpaprika.com/api). |
      | 403 Forbidden | The request could not be processed due to invalid API key. |
      | 404 Not Found | The server could not process the request due to invalid URL or invalid path parameter. |
      | 429 Too Many Requests | The rate limit has been exceeded. Reduce the frequency of requests to avoid this error. |
      | 500 Internal Server Error | An unexpected server error has occured. |
      
   
    # Rate limit
    * The monthly number of requests is limited depending on the plan:
      | Plan       | Calls/month                         |
      |------------|-------------------------------------|
      | Free       | 20 000 |
      | Starter    | 200 000 |
      | Pro        | 500 000 |
      | Business   | 3 000 000 |
      | Enterprise | No limits |

    # API Clients
    We provide the API clients in several popular programming languages:
    * [PHP](https://github.com/coinpaprika/coinpaprika-api-php-client)
    * [NodeJS](https://github.com/coinpaprika/coinpaprika-api-nodejs-client)
    * [GO](https://github.com/coinpaprika/coinpaprika-api-go-client)
    * [Swift](https://github.com/coinpaprika/coinpaprika-api-swift-client)
    * [Kotlin](https://github.com/coinpaprika/coinpaprika-api-kotlin-client)
    * [Python](https://github.com/coinpaprika/coinpaprika-api-python-client)
    * [Google Sheets](https://github.com/coinpaprika/coinpaprika-google-sheet)
    * Community Contributed Clients:
      * [Rust](https://github.com/tokenomia-pro/coinpaprika-api-rust-client) built by <a href="https://tokenomia.pro/" target="_blank">tokenomia.pro</a>
      * [C#](https://github.com/MSiccDev/CoinpaprikaAPI)
      * [JS](https://github.com/jaggedsoft/coinpaprika-js)

    **Note**: some of them may not be updated yet. We are working on improving them and they will be updated soon. If you'd like to contribute, please report issues and send PRs on Github.
    
    
    # Terms of use
    * [Download terms of use](https://coinpaprika.github.io/files/terms_of_use_v1.pdf)
    # Archival documentations
    * [API v1.2](https://api.coinpaprika.com/docs/1.2)
    * [API v1.3](https://api.coinpaprika.com/docs/1.3)
    * [API v1.4](https://api.coinpaprika.com/docs/1.4)
    * [API v1.5](https://api.coinpaprika.com/docs/1.5)
    * [API v1.6](https://api.coinpaprika.com/docs/1.6)
    # Version history
    ## 1.7.9 - 2024.12.18
    * API mappings endpoint documentation
    ## 1.7.8 - 2024.01.24
    * Plan limits update
    ## 1.7.7 - 2023.06.07
    * Added official Python client link
    ## v1.7.6 - 2023.04.12
    * New intervals for OHLCV endpoint
    ## v1.7.5 - 2022.12.07
    * Removed documentation for /beta/ endpoints
    ## v1.7.4 - 2022.09.19
    * Key info endpoint
    * Coin logo image URL
    ## v1.7.3 - 2022.09.08
    * Plans update
    ## v1.7.2 - 2022.07.22
    * Changelog endpoint documentation
    ## v1.7.1 - 2022.07.14
    * Beta endpoints documentation
    ## v1.7.0 - 2022.05.06
    * API-Pro documentation
    ## v1.6.1 - 2020.12.09
    * Added information about first date with price data for currency ticker [/tickers](#operation/getTickers) and [/tickers/{coin_id}](#operation/getTickersById)
    * Added redirect for historical tickers by contract address [/contracts/{platform_id}/{contract_address}/historical](#operation/getHistoricalTicker)
    ## v1.6.0 - 2020.10.27
    * Added contracts section [/contracts](#operation/getPlatforms), [/contracts/{platform_id}](#operation/getContracts),
    [/contracts/{platform_id}/{contract_address}](#operation/getTicker)

servers:
- url: https://api.coinpaprika.com/v1

tags:
- name: "Key"
- name: "Global" 
- name: "Coins"
- name: "People"
- name: "Tags"
- name: "Tickers"
- name: "Exchanges"
- name: "Tools"
- name: "Contracts"
- name: "Changelog"
- name: "Deprecated"

paths:
  # Global
  /key/info:
    $ref: "paths/key.yml#/info"

  # Global
  /global:
    $ref: "paths/global.yml#/global"

  # Coins
  /coins:
    $ref: "paths/coins.yml#/coins"

  /coins/{coin_id}:
    $ref: "paths/coins.yml#/coin_by_id"

  /coins/mappings:
    $ref: "paths/coins.yml#/mappings"

  /coins/{coin_id}/twitter:
    $ref: "paths/coins.yml#/twitter"

  /coins/{coin_id}/events:
    $ref: "paths/coins.yml#/events"

  /coins/{coin_id}/exchanges:
    $ref: "paths/coins.yml#/exchanges_by_coin_id"

  /coins/{coin_id}/markets:
    $ref: "paths/coins.yml#/markets_by_coin_id"

  /coins/{coin_id}/ohlcv/latest/:
    $ref: "paths/coins.yml#/coins_ohlcv_latest"

  /coins/{coin_id}/ohlcv/historical:
    $ref: "paths/coins.yml#/coins_ohlcv_historical"

  /coins/{coin_id}/ohlcv/today/:
    $ref: "paths/coins.yml#/coins_ohlcv_today"

  # People
  /people/{person_id}:
    $ref: "paths/people.yml#/person_by_id"

  # Tags
  /tags:
    $ref: "paths/tags.yml#/tags"
  /tags/{tag_id}:
    $ref: "paths/tags.yml#/tag_by_id"

  # Tickers
  /tickers:
    $ref: "paths/tickers.yml#/tickers"

  /tickers/{coin_id}:
    $ref: "paths/tickers.yml#/tickers_by_id"

  /tickers/{coin_id}/historical:
    $ref: "paths/tickers.yml#/tickers_historical"

  # Exchanges
  /exchanges:
    $ref: "paths/exchanges.yml#/exchanges"
  /exchanges/{exchange_id}:
    $ref: "paths/exchanges.yml#/exchange_by_id"
  /exchanges/{exchange_id}/markets:
    $ref: "paths/exchanges.yml#/markets_by_exchange_id"

  # Contracts
  /contracts:
    $ref: "paths/contracts.yml#/platforms"
  /contracts/{platform_id}:
    $ref: "paths/contracts.yml#/contracts_by_platform"
  /contracts/{platform_id}/{contract_address}:
    $ref: "paths/contracts.yml#/ticker_redirect"
  /contracts/{platform_id}/{contract_address}/historical:
    $ref: "paths/contracts.yml#/ticker_historical_redirect"

  # Changelog
  /changelog/ids:
    $ref: "paths/changelog.yml#/ids"

  # Tools
  /search:
    $ref: "paths/tools.yml#/search"
  /price-converter:
    $ref: "paths/tools.yml#/price_converter"

  # Deprecated
  /ticker:
    $ref: "paths/deprecated.yml#/ticker_deprecated"

  /ticker/{coin_id}:
    $ref: "paths/deprecated.yml#/ticker_by_coin_id_deprecated"
