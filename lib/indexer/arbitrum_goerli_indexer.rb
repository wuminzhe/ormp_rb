# frozen_string_literal: true

require_relative "./indexer_base"

module ArbitrumGoerliIndexer
  extend IndexerBase

  def self.client
    Graphlient::Client.new(
      "https://api.studio.thegraph.com/query/51152/ormpipe-arbitrum-goerli/version/latest",
      headers: {
        "User-Agent": "ORMP Explorer Client"
      }
    )
  end

  define_query_methods(client)
end

# Show all methods
# puts ArbitrumGoerliIndexer.query_methods

# puts ArbitrumGoerliIndexer.ormp_protocol_message_accepteds(blockNumber_lt: 35_978_605)
# puts ArbitrumGoerliIndexer.ormp_protocol_message_accepteds({blockNumber_lt: 35_978_605}, 15)
# puts ArbitrumGoerliIndexer.ormp_protocol_message_accepted(msgHash: "0x6008f795b54410c2995769d443ee1381480fa5cedcb36f8ea7e38f220442c25a")
# puts ArbitrumGoerliIndexer.ormp_protocol_message_accepted

