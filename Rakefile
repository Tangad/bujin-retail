require 'sequel'
require 'rebay'
require_relative 'models/ebay_listing'

desc "Setup Database"
task :setup_db do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/bujin-retail') unless defined?(DB)

  DB.drop_table? :ebay_listings
  DB.create_table :ebay_listings do
    primary_key :id
    String      :external_id,   null: false
    String      :title,         null: false
    String      :thumbnail_url, null: false
    String      :listing_url,   null: false
    BigDecimal  :price,         size: [4, 2], null: false
    column      :end_time, 'timestamp with time zone', null: false
  end
end

desc "Refresh Ebay Listings"
task :refresh_ebay do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/bujin-retail') unless defined?(DB)

  DB.transaction do
    EbayListing.dataset.delete
    Rebay::Api.configure { |rebay| rebay.app_id = ENV['EBAY_APP_ID'] }
    finder = Rebay::Finding.new
    results = finder.find_items_advanced( { categoryId: '45220', 'itemFilter.name' => 'Seller', 'itemFilter.value' => 'bujin_5791' }).results

    results.each do |ebay_result|
      EbayListing.create do |el|
        el.external_id   = ebay_result['itemId']
        el.title         = ebay_result['title']
        el.thumbnail_url = ebay_result['galleryURL']
        el.listing_url   = ebay_result['viewItemURL']
        el.price         = ebay_result['sellingStatus']['currentPrice']['__value__']
        el.end_time      = ebay_result['listingInfo']['endTime']
      end
    end
  end
end
