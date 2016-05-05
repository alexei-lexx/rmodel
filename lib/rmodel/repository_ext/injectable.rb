module Rmodel
  module RepositoryExt
    module Injectable
      def injector
        @injector ||= Injector.new(self)
      end
    end
  end
end
