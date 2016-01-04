module Events
  def define_event (*event_name_symbols)
    event_name_symbols.each do |event_name_symbol|
      handler_name = "when_#{event_name_symbol}".to_sym
      raise_name = "raise_#{event_name_symbol}".to_sym
      var_name = "@#{event_name_symbol}_handlers".to_sym

      self.send(:define_method, handler_name) do |&block|
        if instance_variable_defined? var_name then
          handlers = instance_variable_get(var_name)
        else
          handlers = []
          instance_variable_set(var_name, handlers)
        end

        handlers << block
      end

      self.send(:define_method, raise_name) do |event_args = nil|
        handlers = instance_variable_get(var_name)
        handlers.each { |handler| handler.call(sender: self, data: event_args) } if handlers
      end

      self.send(:private, raise_name)
    end
  end
end

