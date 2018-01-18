require 'xpath/html'

module CornerStones
  class Form
    module Fields
      class AutocompleteField < TextField
        def self.handles?(name)
          all(:xpath, XPath::HTML.fillable_field(name)).any? do |field|
            field[:class] =~ /ui-autocomplete-input/
          end
        end

        def self.handles_element?(element)
          super(element) && element[:class] =~ /ui-autocomplete-input/
        end

        def set(value)
          autocomplete_id = @field[:id]
          super
          page.execute_script %Q{ $('##{autocomplete_id}').trigger("focus") }
          page.execute_script %Q{ $('##{autocomplete_id}').trigger("keydown") }
          wait_until do
            result = page.evaluate_script %Q{ $('.ui-menu-item a:contains("#{value}")').size() }
            result > 0
          end
          page.execute_script %Q{ $('.ui-menu-item a:contains("#{value}")').trigger("mouseenter").trigger("click"); }
        end

        def wait_until
          require "timeout"
          Timeout.timeout(Capybara.default_wait_time) do
            sleep(0.1) until value = yield
            value
          end
        end
      end
    end
  end
end
