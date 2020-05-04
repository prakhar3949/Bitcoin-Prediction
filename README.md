# Bitcoin-Prediction
Bitcoin is the longest running and most well-known cryptocurrency, first released as open
source in 2009 by the anonymous Satoshi Nakamoto. Bitcoin serves as a decentralized
medium of digital exchange, with transactions verified and recorded in a public distributed
ledger (the blockchain) without the need for a trusted record keeping authority or central
intermediary. The dataset includes historical bitcoin market data at 1-min intervals for
select bitcoin exchanges where trading takes place.

# Variable Names:
- Timestamp: Start time of time window (60s window), in Unix time
- Open: Open price at start time window
- High: High price within time window
- Low: Low price within time window
- Close: Close price at end of time window
- Volume_(BTC): Amount of BTC transacted in time window
- Volume_(Currency): Amount of Currency transacted in time window
- Weighted_Price: volume-weighted average price (VWAP)

We would be using time series forecasting methods to predict the price of Bitcoin for future
dates.
