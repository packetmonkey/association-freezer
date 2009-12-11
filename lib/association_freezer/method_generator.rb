module AssociationFreezer
  class MethodGenerator

    def initialize(reflection)
      @reflection = reflection
    end
    
    def generate
      # it is very important that we first make sure this hasn't already been done
      # because otherwise it will result in an endless loop the way alias method works.
            
      return if previously_generated? || !frozen_column_exists?
      
      reflection = @reflection
      
      freezer = "#{reflection.name}_freezer"
      
      generate_method freezer do
        if reflection.macro == :belongs_to
          read_attribute("@#{freezer}") || write_attribute("@#{freezer}", BelongsToFreezer.new(self, reflection))
        elsif reflection.macro == :has_many
          read_attribute("@#{freezer}") || write_attribute("@#{freezer}", HasManyFreezer.new(self, reflection))
        end
      end
      
      generate_method "freeze_#{reflection.name}" do
        send(freezer).freeze
      end
      
      generate_method "unfreeze_#{reflection.name}" do
        send(freezer).unfreeze
      end
      
      generate_method "#{reflection.name}_with_frozen_check" do |*args|
        send(freezer).fetch(*args)
      end
      model_class.alias_method_chain reflection.name, :frozen_check
      
      generate_method "#{reflection.name}_with_frozen_check=" do |*args|
        if send(freezer).frozen?
          # TODO make this a custom exception
          raise "Unable to set #{reflection.name} because association is frozen." 
        else
          send("#{reflection.name}_without_frozen_check=", *args)
        end
      end
      model_class.alias_method_chain "#{reflection.name}=", :frozen_check
    end
    
    private
    
    def previously_generated?
      model_class.instance_methods.include? "freeze_#{@reflection.name}"
    end
    
    def frozen_column_exists?
      model_class.column_names.include? "frozen_#{@reflection.name}"
    end
    
    def model_class
      @reflection.active_record
    end
    
    def generate_method(name, &block)
      model_class.send(:define_method, name, &block)
    end
    
  end
end
