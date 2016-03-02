module Spree
  module Admin
    class SubscriptionsController < Spree::Admin::ResourceController

      before_action :build_ransackable_search, only: :index

      def enable
      end

      def disable
      end

      def cancel
      end

      private

        def build_ransackable_search
          @search = @subscriptions.ransack(params[:q])
          @subscriptions = @search.result.active
        end

    end
  end
end
