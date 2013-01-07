class Node
  def initialize(home_id, node_id, driver)
    @home_id, @node_id, @driver = home_id, node_id, driver
    initialize_query
  end

  def initialize_query
    retrieve_protocol_info
  end

  def query_protocol_info

  end

  def query_wake_up

  end

  def query_manufacturer_specific1

  end

  def query_node_info

  end

  def query_manufacturer_specific2

  end

  def query_versions

  end

  def query_instance

  end

  def query_static

  end

  def query_associations

  end

  def query_neighbors

  end

  def query_session

  end

  def query_dynamic

  end

  def query_configuration

  end

  def query_complete

  end
end
