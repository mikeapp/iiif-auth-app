require 'json'

    Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new
    Riiif::Image.file_resolver.id_to_uri = lambda do |id|
       # http://deliver.odai.yale.edu/content/id/b16d987c-94de-4b9b-8a3a-588310b9ee9d/format/3
       id, sep, format = id.rpartition('-')
       "http://deliver.odai.yale.edu/content/id/#{id}/format/#{format}"
    end

    class NoService
      def initialize(controller)
        puts "Initializing #{controller}"
        hostname = Rails.application.config.iiif_auth_hostname

        service_json = <<~JSON
        {"service": {
            "@context": "http://iiif.io/api/auth/0/context.json",
            "@id": "http://#{hostname}/login",
            "profile": "http://iiif.io/api/auth/0/login",
            "label": "Login to Example Institution",
            "service": [
            {
                "@id": "http://#{hostname}/token",
                "profile": "http://iiif.io/api/auth/0/token"
            },
            {
                "@id": "http://#{hostname}/logout",
                "profile": "http://iiif.io/api/auth/0/logout",
                "label": "Logout from Example Institution"
            }
        ]
        }
        }
        JSON
        @service = JSON.parse(service_json)

        # if user is defined
        @user = controller.current_user
        puts "User: #{@user}"
      end

      def can?(action, image)
        return true if get_format(image) == '1'  # allow access to low res
        return true if ! @user.nil?
        return false
      end

      def has_degraded?(image)
        ! degraded_image_uri(image).nil?
      end

      def degraded_image_uri(image)
        image_host = Rails.application.config.iiif_image_hostname
        return "http://#{image_host}/image-service/#{get_id(image)}-1" if get_format(image) == '3'
        nil
      end

      def service_info(image)
        @service
      end

      private

      def get_format(image)
        id, sep,format = image.id.rpartition('-')
        format
      end

        def get_id(image)
          id, sep,format = image.id.rpartition('-')
          id
        end

    end

    Riiif::Image.authorization_service = NoService