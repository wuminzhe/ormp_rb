require_relative "./indexer_base"

module PangolinIndexer
  extend IndexerBase

  def self.client
    Graphlient::Client.new(
      "https://thegraph-g2.darwinia.network/ormpipe/subgraphs/name/ormpipe-pangolin",
      headers: {
        "User-Agent": "ORMP Explorer Client"
      }
    )
  end

  define_query_methods(client)
end
