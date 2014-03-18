module OpenCL

  # Creates a Buffer
  #
  # ==== Attributes
  #
  # * +context+ - Context the created Buffer will be associated to
  # * +size+ - Size in of the Buffer to be created
  # * +flags+ - a single or an Array of :cl_mem_flags specifying the flags to be used when creating the Buffer
  # * +data+ - if provided, the Pointer (or convertible to Pointer using to_ptr) to the memory area to use
  def self.create_buffer( context, size, flags=OpenCL::Mem::READ_WRITE, host_ptr=nil)
    fs = 0
    if flags.kind_of?(Array) then
      flags.each { |f| fs = fs | f }
    else
      fs = flags
    end
    h = host_ptr
    if h and h.respond_to?(:to_ptr) then
      h = h.to_ptr
    end
    error = FFI::MemoryPointer.new( :cl_int )
    buff = OpenCL.clCreateBuffer(context, flags, size, h, error)
    OpenCL.error_check(error.read_cl_int)
    return Buffer::new( buff )
  end

  def self.create_sub_buffer( buffer, region, type = OpenCL::BUFFER_CREATE_TYPE_REGION, options = {} )
    OpenCL.error_check(OpenCL::INVALID_OPERATION) if buffer.platform.version_number < 1.1
    flags = 0
    if options[:flags] then
      if options[:flags].kind_of?(Array) then
        options[:flags].each { |f| flags = flags | f }
      else
        flags = options[:flags]
      end
    end
    error = FFI::MemoryPointer.new( :cl_int )
    buff = OpenCL.clCreateSubBuffer( buffer, flags, type, region, error)
    OpenCL.error_check(error.read_cl_int)
    return Buffer::new( buff )
  end

  def self.create_from_GL_buffer( context, bufobj, flags=OpenCL::Mem::READ_WRITE )
    fs = 0
    if flags.kind_of?(Array) then
      flags.each { |f| fs = fs | f }
    else
      fs = flags
    end
    error = FFI::MemoryPointer.new( :cl_int )
    buff = OpenCL.clCreateFromGLBuffer( context, fs, bufobj, error )
    OpenCL.error_check(error.read_cl_int)
    return Buffer::new( buff )
  end

  class Buffer < OpenCL::Mem
    layout :dummy, :pointer

    def create_sub_buffer( region, type = OpenCL::BUFFER_CREATE_TYPE_REGION, options = {} )
      OpenCL.create_sub_buffer( self, region, type, options )
    end
  end

end
