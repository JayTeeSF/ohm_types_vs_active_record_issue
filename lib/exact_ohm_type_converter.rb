module ExactOhmTypeConverter

  def invert_hash(_hash)
    _hash.inject({}) {|memo, (k,v)| memo[v] ||= []; memo[v] << k; memo}
  end
  private :invert_hash

  def convert(attr_type_hash)
    convert_inverted(invert_hash(attr_type_hash))
  end

  def convert_inverted(type_attrs_hash)
    type_attrs_hash.each_pair do |data_type, attr_list|
      attr_list.each do |attr_key|
        conversion_block = lambda {read_local(attr_key)}
        if data_type == Time
          conversion_block = lambda {val = read_local(attr_key); Time.at(val.to_i) if val }

        elsif data_type == Date
          conversion_block = lambda {val = read_local(attr_key); val.to_date if val }

        elsif data_type == Integer
          conversion_block = lambda {val = read_local(attr_key); val.to_i if val }
        elsif data_type == Float
          conversion_block = lambda {val = read_local(attr_key); val.to_f if val }

        elsif data_type == Ohm::Types::Boolean
          conversion_block = lambda {val = read_local(attr_key); [true, "true", 1, "1"].include?(val.respond_to?(:downcase) ? val.downcase : val) if val }

        elsif data_type == Hash
          conversion_block = lambda do
            val = read_local(attr_key)
            begin
              Yajl::Parser.parse(val, :check_utf8 => false).to_hash if val
            rescue ::Yajl::ParseError
              val.to_hash
            end
          end

        elsif data_type == String
          conversion_block = lambda { val = read_local(attr_key); val.to_s if val }

        elsif data_type == Array
          conversion_block = lambda do
            val = read_local(attr_key)
            begin
              Yajl::Parser.parse(val, :check_utf8 => false).to_a if val
            rescue ::Yajl::ParseError
              val.to_a
            end
          end

        else
          STDERR.puts "an unexpected data_type found: #{data_type.inspect}; #{data_type.class}"
          conversion_block = lambda { val = read_local(attr_key); val.to_a if val }
        end

        define_method(attr_key, &(conversion_block))
      end
    end
  end
end
