module RWave
  class Message
    class Function
      def self.to_s(func)
        case func
        when APPLICATION_COMMAND_HANDLER then 'APPLICATION_COMMAND_HANDLER'
        when GET_CONTROLLER_CAPABILITIES then 'GET_CONTROLLER_CAPABILITIES'
        when SERIAL_API_SET_TIMEOUTS then 'SERIAL_API_SET_TIMEOUTS'
        when SERIAL_API_GET_CAPABILITIES then 'SERIAL_API_GET_CAPABILITIES'
        when SERIAL_API_SOFT_RESET then 'SERIAL_API_SOFT_RESET'
        when SEND_DATA then 'SEND_DATA'
        when GET_VERSION then 'GET_VERSION'
        when R_F_POWER_LEVEL_SET then 'R_F_POWER_LEVEL_SET'
        when GET_RANDOM then 'GET_RANDOM'
        when MEMORY_GET_ID then 'MEMORY_GET_ID'
        when MEMORY_GET_BYTE then 'MEMORY_GET_BYTE'
        when READ_MEMORY then 'READ_MEMORY'
        when SET_LEARN_NODE_STATE then 'SET_LEARN_NODE_STATE'
        when GET_NODE_PROTOCOL_INFO then 'GET_NODE_PROTOCOL_INFO'
        when SET_DEFAULT then 'SET_DEFAULT'
        when SERIAL_API_GET_INIT_DATA then 'SERIAL_API_GET_INIT_DATA'
        when NEW_CONTROLLER then 'NEW_CONTROLLER'
        when REPLICATION_COMMAND_COMPLETE then 'REPLICATION_COMMAND_COMPLETE'
        when REPLICATION_SEND_DATA then 'REPLICATION_SEND_DATA'
        when ASSIGN_RETURN_ROUTE then 'ASSIGN_RETURN_ROUTE'
        when DELETE_RETURN_ROUTE then 'DELETE_RETURN_ROUTE'
        when REQUEST_NODE_NEIGHBOR_UPDATE then 'REQUEST_NODE_NEIGHBOR_UPDATE'
        when APPLICATION_UPDATE then 'APPLICATION_UPDATE'
        when ADD_NODE_TO_NETWORK then 'ADD_NODE_TO_NETWORK'
        when REMOVE_NODE_FROM_NETWORK then 'REMOVE_NODE_FROM_NETWORK'
        when CREATE_NEW_PRIMARY then 'CREATE_NEW_PRIMARY'
        when CONTROLLER_CHANGE then 'CONTROLLER_CHANGE'
        when SET_LEARN_MODE then 'SET_LEARN_MODE'
        when ASSIGN_SUC_RETURN_ROUTE then 'ASSIGN_SUC_RETURN_ROUTE'
        when ENABLE_SUC then 'ENABLE_SUC'
        when REQUEST_NETWORK_UPDATE then 'REQUEST_NETWORK_UPDATE'
        when SET_SUC_NODE_ID then 'SET_SUC_NODE_ID'
        when DELETE_SUC_RETURN_ROUTE then 'DELETE_SUC_RETURN_ROUTE'
        when GET_SUC_NODE_ID then 'GET_SUC_NODE_ID'
        when REQUEST_NODE_INFO then 'REQUEST_NODE_INFO'
        when REMOVE_FAILED_NODE_ID then 'REMOVE_FAILED_NODE_ID'
        when IS_FAILED_NODE_ID then 'IS_FAILED_NODE_ID'
        when REPLACE_FAILED_NODE then 'REPLACE_FAILED_NODE'
        when GET_ROUTING_INFO then 'GET_ROUTING_INFO'
        when SERIAL_API_SLAVE_NODE_INFO then 'SERIAL_API_SLAVE_NODE_INFO'
        when APPLICATION_SLAVE_COMMAND_HANDLER then 'APPLICATION_SLAVE_COMMAND_HANDLER'
        when SEND_SLAVE_NODE_INFO then 'SEND_SLAVE_NODE_INFO'
        when SEND_SLAVE_DATA then 'SEND_SLAVE_DATA'
        when SET_SLAVE_LEARN_MODE then 'SET_SLAVE_LEARN_MODE'
        when GET_VIRTUAL_NODES then 'GET_VIRTUAL_NODES'
        when IS_VIRTUAL_NODE then 'IS_VIRTUAL_NODE'
        when SET_PROMISCUOUS_MODE then 'SET_PROMISCUOUS_MODE'
        when PROMISCUOUS_APPLICATION_COMMAND_HANDLER then 'PROMISCUOUS_APPLICATION_COMMAND_HANDLER'
        else 'unknown function'
        end
      end

      SERIAL_API_GET_INIT_DATA                = 0x02
      APPLICATION_COMMAND_HANDLER             = 0x04
      GET_CONTROLLER_CAPABILITIES             = 0x05
      SERIAL_API_SET_TIMEOUTS                 = 0x06
      SERIAL_API_GET_CAPABILITIES             = 0x07
      SERIAL_API_SOFT_RESET                   = 0x08

      SEND_DATA                               = 0x13
      GET_VERSION                             = 0x15
      R_F_POWER_LEVEL_SET                     = 0x17
      GET_RANDOM                              = 0x1c
      MEMORY_GET_ID                           = 0x20
      MEMORY_GET_BYTE                         = 0x21
      READ_MEMORY                             = 0x23

      # Not implemented
      SET_LEARN_NODE_STATE                    = 0x40
      # Get protocol info (baud rate, listening, etc.) for a given node
      GET_NODE_PROTOCOL_INFO                  = 0x41
      # Reset controller and node info to default (original) values
      SET_DEFAULT                             = 0x42
      # Not implemented
      NEW_CONTROLLER                          = 0x43
      # Replication isn't implemented (yet)
      REPLICATION_COMMAND_COMPLETE            = 0x44
      # Replication isn't implemented (yet)
      REPLICATION_SEND_DATA                   = 0x45
      # Assign a return route from the specified node to the controller
      ASSIGN_RETURN_ROUTE                     = 0x46
      # Delete all return routes from the specified node
      DELETE_RETURN_ROUTE                     = 0x47
      # Ask the specified node to update its neighbors (then read them from the controller)
      REQUEST_NODE_NEIGHBOR_UPDATE            = 0x48
      # Get a list of supported (and controller) command classes
      APPLICATION_UPDATE                      = 0x49
      # Control the addnode (or addcontroller) process...start, stop, etc.
      ADD_NODE_TO_NETWORK                     = 0x4a
      # Control the removenode (or removecontroller) process...start, stop, etc.
      REMOVE_NODE_FROM_NETWORK                = 0x4b
      # Control the createnewprimary process...start, stop, etc.
      CREATE_NEW_PRIMARY                      = 0x4c
      # Control the transferprimary process...start, stop, etc.
      CONTROLLER_CHANGE                       = 0x4d
      # Put a controller into learn mode for replication/ receipt of configuration info
      SET_LEARN_MODE                          = 0x50
      # Assign a return route to the SUC
      ASSIGN_SUC_RETURN_ROUTE                 = 0x51
      # Make a controller a Static Update Controller
      ENABLE_SUC                              = 0x52
      # Network update for a SUC(?)
      REQUEST_NETWORK_UPDATE                  = 0x53
      # Identify a Static Update Controller node id
      SET_SUC_NODE_ID                         = 0x54
      # Remove return routes to the SUC
      DELETE_SUC_RETURN_ROUTE                 = 0x55
      # Try to retrieve a Static Update Controller node id (zero if no SUC present)
      GET_SUC_NODE_ID                         = 0x56
      # Get info (supported command classes) for the specified node
      REQUEST_NODE_INFO                       = 0x60
      # Mark a specified node id as failed
      REMOVE_FAILED_NODE_ID                   = 0x61
      # Check to see if a specified node has failed
      IS_FAILED_NODE_ID                       = 0x62
      # Remove a failed node from the controller's list (?)
      REPLACE_FAILED_NODE                     = 0x63
      # Get a specified node's neighbor information from the controller
      GET_ROUTING_INFO                        = 0x80
      # Set application virtual slave node information
      SERIAL_API_SLAVE_NODE_INFO              = 0xA0
      # Slave command handler
      APPLICATION_SLAVE_COMMAND_HANDLER       = 0xA1
      # Send a slave node information frame
      SEND_SLAVE_NODE_INFO                    = 0xA2
      # Send data from slave
      SEND_SLAVE_DATA                         = 0xA3
      # Enter slave learn mode
      SET_SLAVE_LEARN_MODE                    = 0xA4
      # Return all virtual nodes
      GET_VIRTUAL_NODES                       = 0xA5
      # Virtual node test
      IS_VIRTUAL_NODE                         = 0xA6
      # Set controller into promiscuous mode to listen to all frames
      SET_PROMISCUOUS_MODE                    = 0xD0

      PROMISCUOUS_APPLICATION_COMMAND_HANDLER = 0xD1
    end
  end
end
