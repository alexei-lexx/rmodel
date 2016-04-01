module Rmodel
  module RepositoryExt
    module Sugarable
      def find!(id)
        find(id) or fail(Rmodel::NotFound.new(self, id: id))
      end

      def insert(*args)
        if args.length == 1
          if args.first.is_a?(Array)
            insert_array(args.first)
          else
            insert_one(args.first)
          end
        else
          insert_array(args)
        end
      end

      def save(object)
        if object.id.nil?
          insert_one(object)
        else
          update(object)
        end
      end

      def remove_all
        query.remove
      end

      def destroy_all
        query.destroy
      end

      private

      def insert_array(array)
        array.each { |object| insert_one(object) }
      end
    end
  end
end
