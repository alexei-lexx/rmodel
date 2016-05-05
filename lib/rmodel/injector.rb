require 'lazy_object'

module Rmodel
  class Injector < Module
    def initialize(repository_class)
      @repository = LazyObject.new { repository_class.new }
    end

    def included(base)
      add_method_missing(base)
    end

    def extended(base)
      included(base)
    end

    private

    def add_method_missing(base)
      repository = @repository
      injector = self

      base.define_singleton_method :method_missing do |name, *args|
        if repository.respond_to?(name)
          injector.send(:delegate_to_repository, self, name, *args)
        else
          super(name, *args)
        end
      end
    end

    def delegate_to_repository(base, name, *delegated_args)
      repository = @repository

      base.define_singleton_method name do |*args|
        repository.public_send(name, *args)
      end

      base.public_send(name, *delegated_args)
    end
  end
end
