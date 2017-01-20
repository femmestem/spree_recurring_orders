Spree Recurring Orders
===========================

Spree Recurring Orders is an extension to let users have time interval based subscription of products in a spree application.

* This extension allows the admin to create a subscribable product on the Admin end.

* This product can then be bought one-time or as a subscription.

* Once subscribed, subscription orders will automatically be created for the customer at the selected time interval until cancelled by the customer or admin.

Installation
------------

Add spree_recurring_orders to your Gemfile:

```ruby
gem 'spree_recurring_orders', github: 'femmestem/spree_recurring_orders'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_recurring_orders:install
```

You can also seed the default data with:
```shell
bundle exec rails g spree_recurring_orders:seed
```

Working
-------

* Admin can mark a product as "subscribable" on the `Admin -> Products -> Edit` page. The admin will have to choose the subscription frequencies to be made available for that product.

* Subscription frequencies are created by default when you seed data. You can also add subscription frequencies through `Admin -> Configurations -> Subscription Frequencies -> New` page.

* When purchasing a subscribable product, user is given an option to make it a 'One Time Order' or a 'Subscription Order'.

* When making a 'Subscription Order', the user will have to choose Quantity and Delivery Interval. The first order will be made on checkout and recurring orders will automatically be created for the user at the selected time intervals.

* The users can check their subscriptions on the 'My Account' page. They can update subscription info, pause or cancel their subscriptions via the `Subscription -> Edit` page.

* A cron job needs to be run to process subscriptions
  ```
  bundle exec rake subscription:process
  ```
  This will run the pending subscriptions.

* A cron job can also be run to notify users of upcoming subscriptions:
  ```
  bundle exec rake subscription:prior_notify
  ```
  This will inform users that they have a subscription that is coming up in 'x' days. The number of days can be changed on subscription edit page.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_recurring_orders/factories'
```

Credits
-------

Copyright (c) 2016 Christine Feaster, [christine.codes](http://christine.codes), released under the New MIT License

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/themes/vinsoldotcom-theme/images/new_img/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
