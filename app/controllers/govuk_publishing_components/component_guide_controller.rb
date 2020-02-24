module GovukPublishingComponents
  class ComponentGuideController < GovukPublishingComponents::ApplicationController
    append_view_path File.join(Rails.root, "app", "views", GovukPublishingComponents::Config.component_directory_name)

    def index
      @component_docs = component_docs.all
      @gem_component_docs = gem_component_docs.all
      @components_in_use_docs = components_in_use_docs.used_in_this_app
      @components_in_use_sass = components_in_use_sass(false)
      @components_in_use_print_sass = components_in_use_sass(true)
    end

    def show
      @component_doc = component_docs.get(params[:component])
      @guide_breadcrumbs = [index_breadcrumb, component_breadcrumb(@component_doc)]
    end

    def example
      @component_doc = component_docs.get(params[:component])
      @component_example = @component_doc.examples.find { |f| f.id == params[:example] }
      @guide_breadcrumbs = [
                             index_breadcrumb,
                             component_breadcrumb(@component_doc, @component_example),
                             {
                               title: @component_example.name
                             }
                           ]
    end

    def preview
      @component_examples = []
      @component_doc = component_docs.get(params[:component])
      @preview = true

      if params[:example].present?
        @component_examples.push(@component_doc.examples.find { |f| f.id == params[:example] })
      else
        @component_examples = @component_doc.examples
      end
    end

    def components_in_use_sass(print_styles)
      print_path = "print/" if print_styles
      additional_files = "@import 'govuk_publishing_components/govuk_frontend_support';\n"
      additional_files << "@import 'govuk_publishing_components/component_support';\n" unless print_styles

      components = components_in_use
      extra_components = []

      components.each do |component|
        components_in_component = components_within_component(component)
        extra_components << components_in_component
      end

      components << extra_components.compact
      components = components.flatten.uniq.sort

      components.map { |component|
        "@import 'govuk_publishing_components/components/#{print_path}_#{component.gsub('_', '-')}';" if component_has_sass_file(component.gsub('_', '-'), print_styles)
      }.join("\n").squeeze("\n").prepend(additional_files)
    end

  private

    def component_docs
      @component_docs ||= ComponentDocs.new
    end

    def gem_component_docs
      @gem_component_docs ||= ComponentDocs.new(gem_components: true)
    end

    def components_in_use_docs
      @components_in_use_docs ||= ComponentDocs.new(gem_components: true, limit_to: components_in_use)
    end

    def components_in_use
      matches = []

      files = Dir["#{Rails.root}/app/views/**/*.html.erb"]
      files.each do |file|
        data = File.read(file)
        matches << data.scan(/(govuk_publishing_components\/components\/[a-z_-]+)/)
      end

      matches.flatten.uniq.map(&:to_s).sort.map { |m| m.gsub('govuk_publishing_components/components/', '') }
    end

    def component_has_sass_file(component, print_styles)
      print_path = "print/" if print_styles
      Pathname.new(__dir__ + "/../../assets/stylesheets/govuk_publishing_components/components/#{print_path}_#{component}.scss").exist?
    end

    def components_within_component(component)
      data = File.read(Pathname.new(__dir__ + "/../../views/govuk_publishing_components/components/_#{component}.html.erb"))
      match = data.scan(/(govuk_publishing_components\/components\/[a-z_-]+)/)
      match.flatten.uniq.map(&:to_s).sort.map { |m| m.gsub('govuk_publishing_components/components/', '') }
    end

    def index_breadcrumb
      {
        title: GovukPublishingComponents::Config.component_guide_title,
        url: component_guide_path
      }
    end

    def component_breadcrumb(component_doc, component_example = nil)
      Hash.new.tap do |h|
        h[:title] = component_doc.name
        h[:url] = component_doc_path(component_doc.id) if component_example
      end
    end
  end
end
