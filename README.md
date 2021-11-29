# LND::Tool [![Build Status](https://github.com/azuchi/lnd-tool/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/azuchi/lnd-tool/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/lnd-tool.svg)](https://badge.fury.io/rb/lnd-tool) [![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

This is a tool for LND written in Ruby. Subscribe to htlc events in LND and save their contents to SQLite3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lnd-tool'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lnd-tool

## Usage

### Configuration

First, create a configuration file for the gRPC connection to LND.

* config.yml

```yaml
lnd:
  credentials_path: 'Path to credential file like $LND_HOME/tls.cert.'
  macaroon_path: 'Path to the macaroon file created by lnd like $LND_HOME/data/chain/bitcoin/mainnet/admin.macaroon'
  host: 'lnd host'
  port: 10009 # gRPC port
```

### Capture HTLC events

Run following command specifying the above configuration file.

    $ lnd-tool capture_htlc --config "Path to configuration file"

Run process in the background as a daemon and starts capturing the HTLC event.

A directory `$HOME/.lnd-tool` will be created and a SQLite3 database named `storage.db`
will be created in it. You can access this database:

    $ sqlite3 $HOME/.lnd-tool
    SQLite version 3.27.2 2019-02-25 16:06:06
    Enter ".help" for usage hints.
    sqlite> .tables
    HtlcEvent
    sqlite> .header on
    sqlite> .mode column
    sqlite> select * from HtlcEvent;
    id          incoming_channel_id  outgoing_channel_id  incoming_htlc_id  outgoing_htlc_id  timestamp_ns         event_type  forward_event  forward_fail_event  settle_event  link_fail_event                                                                                                                                                                                                                                                     created_datetime
    ----------  -------------------  -------------------  ----------------  ----------------  -------------------  ----------  -------------  ------------------  ------------  --------------------------------------------------------------------------------------------------------------------                                                                                                                                                -------------------
    1           759077539161571329   781080965883559937   201               0                 1637643738317254952  FORWARD                                                      {"info":{"incomingTimelock":711047,"outgoingTimelock":711007,"incomingAmtMsat":"250004750","outgoingAmtMsat":"250001250"},"wireFailure":"TEMPORARY_CHANNEL_FAILURE","failureDetail":"INSUFFICIENT_BALANCE","failureString":"insufficient bandwidth to route htlc"}  2021-11-23 14:02:18
    2           759077539161571329   781080965883559937   202               0                 1637643771224622997  FORWARD                                                      {"info":{"incomingTimelock":711047,"outgoingTimelock":711007,"incomingAmtMsat":"973389706","outgoingAmtMsat":"973378973"},"wireFailure":"TEMPORARY_CHANNEL_FAILURE","failureDetail":"INSUFFICIENT_BALANCE","failureString":"insufficient bandwidth to route htlc"}  2021-11-23 14:02:51

If you stop the capturing, run following command:

    $ lnd-tool stop_capture

### Search HTLC events

You can use the `query_htlc` command to retrieve the data of HTLC events stored in SQLite3.
Since it is a search to the database, it can be run even if the capture process is not running.

    $ lnd-tool query_htlc
    +------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    |                                                                                    HTLC Events                                                                                     |
    +--------------------+---------------+--------------------+---------------+---------------------------+------------+--------------+------------------+---------------+---------------+
    | incoming channel   | incoming htlc | outgoing channel   | outgoing htlc | timestamp                 | event type | result       | detail           | incoming msat | outgoing msat |
    +--------------------+---------------+--------------------+---------------+---------------------------+------------+--------------+------------------+---------------+---------------+
    | 759077539161571329 |           259 | 781080965883559937 |             0 | 2021-11-29 13:29:57 +0900 | FORWARD    | LINK_FAIL    | FEE_INSUFFICIENT |      75002825 |      75001075 |
    | 759526139822866433 |            32 | 759077539161571329 |           441 | 2021-11-25 16:34:48 +0900 | FORWARD    | FORWARD FAIL |                  |               |               |
    | 759526139822866433 |            32 | 759077539161571329 |           441 | 2021-11-25 16:34:44 +0900 | FORWARD    | FORWARD      |                  |     100050900 |     100000000 |
    | 759526139822866433 |            31 | 759077539161571329 |           440 | 2021-11-25 16:34:39 +0900 | FORWARD    | FORWARD FAIL |                  |               |               |
    | 759526139822866433 |            31 | 759077539161571329 |           440 | 2021-11-25 16:34:36 +0900 | FORWARD    | FORWARD      |                  |         11005 |         10000 |
    +--------------------+---------------+--------------------+---------------+---------------------------+------------+--------------+------------------+---------------+---------------+

The `query_htlc` command has the following options.

* `event`: Option to specify the event type(`send`, `receive`, `forward`). e.g. `$ lnd-tool query_htlc --event=forward`
* `limit`: Option to narrows down the number of data. e.g. `$lnd-tool query_htlc --limit=30`