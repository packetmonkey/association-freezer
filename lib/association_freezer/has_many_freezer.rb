module AssociationFreezer
  class HasManyFreezer
    def initialize(owner, reflection)
      @owner = owner
      @reflection = reflection
    end
    
    def freeze
      self.frozen_data = Marshal.dump(nonfrozen.attributes) if nonfrozen
    end
    
    def unfreeze
      @frozen = nil
      self.frozen_data = nil
    end
    
    def fetch(*args)
      frozen || nonfrozen(*args)
    end
    
    def frozen?
      frozen_data
    end
    
    private
    
    def frozen
      @frozen ||= load_frozen if frozen?
    end
    
    def load_frozen
      attributes = Marshal.load(frozen_data)
      target = target_class.new(attributes.except('id'))
      target.id = attributes['id']
      target.instance_variable_set('@new_record', false)
      target.readonly!
      target.freeze
    end
    
    def nonfrozen(*args)
      @owner.send("#{name}_without_frozen_check", *args)
    end
    
    def frozen_data=(data)
      @owner.write_attribute("frozen_#{name}", data)
    end
    
    def frozen_data
      @owner.read_attribute("frozen_#{name}")
    end
    
    def target_class
      @reflection.klass
    end
    
    def name
      @reflection.name
    end
  end
end
