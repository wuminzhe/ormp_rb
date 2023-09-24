# frozen_string_literal: true

require_relative "ormp_rb/version"
require "thor"
require_relative "./indexer/arbitrum_goerli_indexer"
require_relative "./indexer/pangolin_indexer"
require_relative "./message_relay"

module OrmpRb
  class Relayer < Thor # :nodoc:
    desc "start_message_relay", "start_message_relay"
    def start_message_relay
      MessageRelay.src_indexer = ArbitrumGoerliIndexer
      MessageRelay.dst_indexer = PangolinIndexer

      loop do
        MessageRelay.relay
      end
    end
  end
end

OrmpRb::Relayer.start(ARGV)
