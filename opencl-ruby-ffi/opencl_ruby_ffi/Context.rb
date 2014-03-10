module OpenCL

  def OpenCL.create_context(devices, properties=nil, &block)
    @@callbacks.push( block ) if block
    pointer = FFI::MemoryPointer.new( Device, devices.size)
    pointer_err = FFI::MemoryPointer.new( :cl_int )
    devices.size.times { |indx|
      pointer.put_pointer(indx, devices[indx])
    }
    ptr = OpenCL.clCreateContext(nil, devices.size, pointer, block, nil, pointer_err)
    OpenCL.error_check(pointer_err.read_cl_int)
    return OpenCL::Context::new(ptr)
  end

#  def OpenCL.create_context_from_type(type, properties = {}, &block)
#    @@callbacks.push( block ) if block
#    OpenCL.clCreateContextFromType(
#  end

  class Context

    %w( REFERENCE_COUNT ).each { |prop|
      eval OpenCL.get_info("Context", :cl_uint, prop)
    }
    eval OpenCL.get_info_array("Context", :cl_context_properties, "PROPERTIES")

    def platform
      self.devices.first.platform
    end

    def num_devices
      d_n = 0
      ptr = FFI::MemoryPointer.new( :size_t )
      error = OpenCL.clGetContextInfo(self, Context::DEVICES, 0, nil, ptr)
      OpenCL.error_check(error)
      d_n = ptr.read_size_t / Platform.size
#      else
#        ptr = FFI::MemoryPointer.new( :cl_uint )
#        error = OpenCL.clGetContextInfo(self, Context::NUM_DEVICES, ptr.size, ptr, nil)
#        OpenCL.error_check(error)
#        d_n = ptr.read_cl_uint
#      end
      return d_n
    end

    def devices
      n = self.num_devices
      ptr2 = FFI::MemoryPointer.new( Device, n )
      error = OpenCL.clGetContextInfo(self, Context::DEVICES, Device.size*n, ptr2, nil)
      OpenCL.error_check(error)
      return ptr2.get_array_of_pointer(0, n).collect { |device_ptr|
        OpenCL::Device.new(device_ptr)
      }
    end

    def create_command_queue(device, properties=[])
      return OpenCL.create_command_queue(self, device, properties)
    end

    def create_buffer(size, flags=OpenCL::Mem::READ_WRITE, data=nil)
      return OpenCL.create_buffer(self, size, flags, data)
    end

    def create_program_with_source( strings )
      return OpenCL.create_program_with_source(self, strings)
    end

  end
end

