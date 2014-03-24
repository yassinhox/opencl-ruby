module OpenCL

  
  # Attaches a callback to event that will be called on the given transition
  #
  # ==== Attributes
  #
  # * +event+ - the Event to attach the callback to
  # * +options+ - a hash containing named options
  # * +block+ - a callback invoked when the given event occurs. Signature of the callback is { |Event, :cl_int event_command_exec_status, FFI::Pointer to user_data| ... }
  #
  # ==== Options
  #
  # * +:user_data+ - a Pointer (or convertible to Pointer using to_ptr) to the memory area to pass to the callback
  def self.set_event_callback( event, command_exec_callback_type, options = {}, &proc )
    OpenCL.error_check(OpenCL::INVALID_OPERATION) if event.context.platform.version_number < 1.1
    error = OpenCL.clSetEventCallback( event, command_exec_callback_type, proc, options[:user_data] )
    OpenCL.error_check(error)
    return self
  end

  # Creates a user Event
  #
  # ==== Attributes
  #
  # * +context+ - Context the created Event will be associated to
  def self.create_user_event(context)
    OpenCL.error_check(OpenCL::INVALID_OPERATION) if context.platform.version_number < 1.1
    error = FFI::MemoryPointer::new(:cl_int)
    event = OpenCL.clCreateUserEvent(context, error)
    OpenCL.error_check(error.read_cl_int)
    return Event::new(event, false)
  end

  # Sets the satus of user Event to the given execution status
  def self.set_user_event_status( event, execution_status )
    OpenCL.error_check(OpenCL::INVALID_OPERATION) if event.context.platform.version_number < 1.1
    error = OpenCL.clSetUserEventStatus( event, execution_status )
    OpenCL.error_check(error)
    return self
  end

  # Creates an event from a GL sync object
  #
  # ==== Attributes
  #
  # * +context+ - Context the created Event will be associated to
  # * +sync+ - a :GLsync representing the name of the sync object
  def self.create_event_from_GL_sync_KHR( context, sync )
    error = FFI::MemoryPointer::new(:cl_int)
    event = OpenCL.clCreateEventFromGLsyncKHR(context, sync, error)
    OpenCL.error_check(error.read_cl_int)
    return Event::new(event, false)
  end

  # Maps the cl_event object
  class Event

    # Returns the CommandQueue associated with the Event, if it exists
    def command_queue
      ptr = FFI::MemoryPointer::new( CommandQueue )
      error = OpenCL.clGetEventInfo(self, Event::COMMAND_QUEUE, CommandQueue.size, ptr, nil)
      OpenCL.error_check(error)
      pt = ptr.read_pointer
      if pt.null? then
        return nil
      else
        return OpenCL::CommandQueue::new( pt )
      end
    end

    # Returns the Context associated with the Event
    def context
      ptr = FFI::MemoryPointer::new( Context )
      error = OpenCL.clGetEventInfo(self, Event::CONTEXT, Context.size, ptr, nil)
      OpenCL.error_check(error)
      return OpenCL::Context::new( ptr.read_pointer )
    end

    # Returns a CommandType corresponding to the type of the command associated with the Event
    eval OpenCL.get_info("Event", :cl_command_type, "COMMAND_TYPE")

    # Returns a CommandExecutionStatus corresponding to the status of the command associtated with the Event
    def command_execution_status
      ptr = FFI::MemoryPointer::new( :cl_int )
      error = OpenCL.clGetEventInfo(self, OpenCL::Event::COMMAND_EXECUTION_STATUS, ptr.size, ptr, nil )
      OpenCL.error_check(error)
      return OpenCL::CommandExecutionStatus::new( ptr.read_cl_int )
    end

    ##
    # :method: reference_count()
    # Returns the reference counter of th Event
    eval OpenCL.get_info("Event", :cl_uint, "REFERENCE_COUNT")

    # Returns the date the command corresponding to Event was queued
    def profiling_command_queued
       ptr = FFI::MemoryPointer::new( :cl_ulong )
       error = OpenCL.clGetEventProfilingInfo(self, OpenCL::PROFILING_COMMAND_QUEUED, ptr.size, ptr, nil )
       OpenCL.error_check(error)
       return ptr.read_cl_ulong
    end

    # Returns the date the command corresponding to Event was submited
    def profiling_command_submit
       ptr = FFI::MemoryPointer::new( :cl_ulong )
       error = OpenCL.clGetEventProfilingInfo(self, OpenCL::PROFILING_COMMAND_SUBMIT, ptr.size, ptr, nil )
       OpenCL.error_check(error)
       return ptr.read_cl_ulong
    end

    # Returns the date the command corresponding to Event started
    def profiling_command_start
       ptr = FFI::MemoryPointer::new( :cl_ulong )
       error = OpenCL.clGetEventProfilingInfo(self, OpenCL::PROFILING_COMMAND_START, ptr.size, ptr, nil )
       OpenCL.error_check(error)
       return ptr.read_cl_ulong
    end

    # Returns the date the command corresponding to Event ended
    def profiling_command_end
       ptr = FFI::MemoryPointer::new( :cl_ulong )
       error = OpenCL.clGetEventProfilingInfo(self, OpenCL::PROFILING_COMMAND_END, ptr.size, ptr, nil )
       OpenCL.error_check(error)
       return ptr.read_cl_ulong
    end

    # Sets the satus of Event (a user event) to the given execution status
    def set_user_event_status( execution_status )
      return OpenCL.set_user_event_status( self, execution_status )
    end

    alias :set_status :set_user_event_status

    # Attaches a callback to the Event that will be called on the given transition
    #
    # ==== Attributes
    #
    # * +options+ - a hash containing named options
    # * +block+ - a callback invoked when the given Event occurs. Signature of the callback is { |Event, :cl_int event_command_exec_status, FFI::Pointer to user_data| ... }
    #
    # ==== Options
    #
    # * +:user_data+ - a Pointer (or convertible to Pointer using to_ptr) to the memory area to pass to the callback
    def set_event_callback( command_exec_callback_type, options={}, &proc )
      return OpenCL.set_event_callback( self, command_exec_callback_type, options={}, &proc )
    end

    alias :set_callback :set_event_callback

  end
end