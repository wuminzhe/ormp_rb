# frozen_string_literal: true

module MessageRelay # :nodoc:
  class << self
    attr_accessor :src_indexer, :dst_indexer

    def relay
      # Get the latest accepted message on source chain to relay
      message = src_indexer.ormp_protocol_message_accepted
      return if message.nil?

      # Check if the message has been relayed
      return if relayed?(message)

      # Check if the message root is ready
      return unless message_root_ready?(message)

      do_relay(message)
    end

    private

    def relayed?(message)
      latest_dispatched_message = latest_dispatched_message_on_source
      return false if latest_dispatched_message.nil?

      message["message_index"] <= latest_dispatched_message["message_index"]
    end

    def message_root_ready?(message)
      latest_aggregated_message = latest_aggregated_message_on_source
      return false if latest_aggregated_message.nil?

      message["blockNumber"] <= latest_aggregated_message["blockNumber"]
    end

    def do_relay(message)
      puts message
    end

    def latest_dispatched_message_on_source
      latest_dispatched_message = dst_indexer.ormp_protocol_message_dispatched
      return if latest_dispatched_message.nil?

      src_indexer.ormp_protocol_message_accepted(
        msgHash: latest_dispatched_message["msgHash"]
      )
    end

    def latest_aggregated_message_on_source
      latest_aggregated_message_root = dst_indexer.airnode_dapi_aggregated_message_root
      return if latest_aggregated_message_root.nil?

      src_indexer.ormp_protocol_message_accepted(
        root: latest_aggregated_message_root["msgRoot"]
      )
    end
  end
end
