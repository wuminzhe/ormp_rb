# frozen_string_literal: true

require "graphlient"

module IndexerBase
  def query(client, name, fields, n: 1, conditions: {}, order_by: "blockNumber", order_direction: "desc")
    snake_name = name.underscore
    query_str = <<~GRAPHQL
      query {
        #{name}(
          orderBy: #{order_by}
          orderDirection: #{order_direction}
          first: #{n}
          #{where_clause(conditions)}
        ) {
          #{fields.join("\n    ")}
        }
      }
    GRAPHQL
    puts query_str

    response = client.query(query_str)
    response.data.send(snake_name).map(&:to_h)
  end

  def define_query_methods(client)
    client.schema.graphql_schema.types.each do |name, type|
      next unless (
        name.start_with?("Ormp") || name.start_with?("AirnodeRrp") || name.start_with?("Aggregated")
      ) && (!name.end_with?("_filter") && !name.end_with?("_orderBy"))

      fields = type.fields.keys

      # example:
      #   name: OrmpOracleAssigned
      #
      #   graphql_schema_name: ormpOracleAssigneds
      #
      #   query_method_name: ormp_oracle_assigneds
      #   find_method_name: ormp_oracle_assigned
      graphql_schema_name = "#{name[0].downcase}#{name[1..]}s"

      query_method_name = "#{name.underscore}s"
      define_singleton_method query_method_name do |conditions = {}, n = 10, order_by = "blockNumber", order_direction = "desc"|
        query(client, graphql_schema_name, fields, n: n, conditions: conditions, order_by: order_by, order_direction: order_direction)
      end

      find_method_name = name.underscore
      define_singleton_method find_method_name do |conditions = {}, order_by = "blockNumber", order_direction = "desc"|
        query(client, graphql_schema_name, fields, n: 1, conditions: conditions, order_by: order_by, order_direction: order_direction).first
      end
    end

    def query_methods
      singleton_methods.filter do |method|
        method.name != "client" &&
          method.name != "query" &&
          method.name != "query_methods" &&
          method.name != "define_query_methods"
      end
    end
  end
end

class String
  def underscore
    gsub(/::/, "/")
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end
end

def where_clause(conditions)
  return "" if conditions.empty?
  
  body = conditions.map do |k, v| 
    if v.instance_of?(String)
      "#{k}: \"#{v}\""
    else
      "#{k}: #{v}"
    end
  end.join(", ")
  "where: {#{body}}"
end
