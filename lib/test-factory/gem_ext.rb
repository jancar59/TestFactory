# We are extending Watir's element methods here with the #fit method,
# which can be used with text fields, select lists, radio buttons,
# and checkboxes.
#
# The purpose of #fit is to allow the creation, in your Data Object classes,
# of a minimal number of #edit methods (ideally only one) written as
# concisely as possible.
#
# Without the #fit method, you would either have to write separate edit
# methods for every possible field you want to edit, or else your
# edit method would have to contain lots of repetitive conditional code
# to prevent making edits to those fields that don't need it.
#
# Proper use of the #fit method requires following a particular coding
# pattern, however:
#
# 1. In your Page Classes, define your radio buttons and checkboxes
# directly. Do not define #set and/or #clear actions there.
# 2. Your data object's instance variables for radio buttons and
# checkboxes should have the values of +:set+ or +:clear+. If they *need* to be
# something else, then define a Hash transform method to easily
# convert the custom values back to +:set+ or +:clear+, then pass that
# transform to the #fit method.
# 3. Always remember to end your #edit methods with the #set_options()
# method, from the DataFactory module. It automatically takes care
# of updating your data object's instance variables with any
# new values.
#
# ==Example
#
# Let's take a look at how the proper use of #fit in your code can significantly
# clean things up.
#
# First, here's some code written without using #fit, and using
# actions for the checkbox page objects, and a Data Object
# instance variable that is either "YES" or "NO"...
#
#   class MyPage < BasePage
#     # ...
#     action(:check_checkbox) { |b| b.checkbox(id: "checkbox").set }
#     action(:clear_checkbox) { |b| b.checkbox(id: "checkbox").clear }
#     # ...
#   end
#
#   class DataObject
#     # ...
#     def edit opts={}
#       # ...
#       if opts[:option] != @option
#         on MyPage do |page|
#           if opts[:option] == "NO"
#             page.clear_checkbox
#           else
#             page.check_checkbox
#           end
#         end
#         @option = opts[:option]
#       end
#       # ...
#     end
#     # ...
#   end
#
# Now, let's take that same code, but this time use the #fit method, set up
# the data object's instance variable correctly as +:set+ or +:clear+, and
# end the #edit with #set_options ...
#
#   class MyPage < BasePage
#     # ...
#     element(:checkbox) { |b| b.checkbox(id: "checkbox") }
#     # ...
#   end
#
#   class DataObject
#     # ...
#     def edit opts={}
#       # ...
#       on MyPage do |page|
#         # ...
#         page.checkbox.fit opts[:option]
#         # ...
#       end
#       # ...
#       update_options opts
#     end
#     # ...
#   end
#
# If you absolutely _must_ have your data object's instance variable be something
# other than +:set+ or +:clear+, then consider writing private a "transform" method
# in your data object class, like this:
#
#   def checkbox_trans
#     { "YES" => :set, "NO" => :clear }
#   end
#
# Then use that transform with your #fit method, like this:
#
#   page.checkbox.fit checkbox_trans[opts[:option]]
#
module Watir
  module UserEditable

    # Extends Watir's methods.
    # Use when the argument you are passing to a text field
    # may be nil, in which case you don't
    # want to do anything with the page element.
    def fit(args)
      unless args==nil
        assert_exists
        assert_writable

        @element.clear
        @element.send_keys(args)
      end
    end
  end

  class Select
    # Extends Watir's methods.
    # Use when the argument you are passing to a text field
    # may be nil, in which case you don't
    # want to do anything with the page element.
    def fit(str_or_rx)
      select_by :text, str_or_rx unless str_or_rx==nil
    end
  end

end