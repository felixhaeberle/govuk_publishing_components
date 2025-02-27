require "rails_helper"

describe "Step by step navigation related", type: :view do
  def component_name
    "step_by_step_nav_related"
  end

  def one_link
    [
      {
        href: "/link1",
        text: "Link 1",
      },
    ]
  end

  def two_links
    [
      {
        href: "/link1",
        text: "Link 1",
      },
      {
        href: "/link2",
        text: "Link 2",
      },
    ]
  end

  def one_link_with_tracking
    [
      {
        href: "/link1",
        text: "Link 1",
        tracking_id: "peter",
      },
    ]
  end

  def two_links_with_tracking
    [
      {
        href: "/link1",
        text: "Link 1",
        tracking_id: "peter",
      },
      {
        href: "/link2",
        text: "Link 2",
        tracking_id: "paul",
      },
    ]
  end

  it "renders nothing without passed content" do
    assert_empty render_component({})
  end

  it "displays one link inside a heading" do
    render_component(links: one_link)

    this_link = ".gem-c-step-nav-related .gem-c-step-nav-related__heading .govuk-link"

    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__heading .gem-c-step-nav-related__pretitle", text: "Part of"
    assert_select "#{this_link}[href='/link1']", text: "Link 1"
    assert_select "#{this_link}[data-track-category='stepNavPartOfClicked']"
    assert_select "#{this_link}[data-track-action='Part of']"
    assert_select "#{this_link}[data-track-label='/link1']"
    assert_select "#{this_link}[data-track-dimension='Link 1']"
    assert_select "#{this_link}[data-track-dimension-index='29']"
  end

  it "displays more than one link in a list" do
    render_component(links: two_links)

    this_link = ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link2']"

    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__heading .gem-c-step-nav-related__pretitle", text: "Part of"
    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link1']", text: "Link 1"
    assert_select this_link, text: "Link 2"
    assert_select "#{this_link}[data-track-category='stepNavPartOfClicked']"
    assert_select "#{this_link}[data-track-action='Part of']"
    assert_select "#{this_link}[data-track-label='/link2']"
    assert_select "#{this_link}[data-track-dimension='Link 2']"
    assert_select "#{this_link}[data-track-dimension-index='29']"
  end

  it "shows alternative heading text" do
    render_component(links: one_link, pretitle: "Moo")

    assert_select ".gem-c-step-nav-related__pretitle", text: "Moo"
    assert_select ".govuk-link[data-track-action='Moo']"
  end

  it "adds a tracking id to one link" do
    render_component(links: one_link_with_tracking)

    assert_select ".gem-c-step-nav-related .govuk-link[data-track-options='{\"dimension96\" : \"peter\" }']"
  end

  it "adds a tracking id to every link when there are more than one" do
    render_component(links: two_links_with_tracking)

    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__link-item:nth-child(1) .govuk-link[data-track-options='{\"dimension96\" : \"peter\" }']"
    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__link-item:nth-child(2) .govuk-link[data-track-options='{\"dimension96\" : \"paul\" }']"
  end

  it "displays as a list when always_display_as_list is passed in" do
    render_component(links: one_link, always_display_as_list: true)

    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__heading .gem-c-step-nav-related__pretitle", text: "Part of"
    assert_select ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link1']", text: "Link 1"
  end

  it "adds GA4 data attributes when ga4_tracking is true" do
    render_component(links: one_link, ga4_tracking: true)

    this_link = ".gem-c-step-nav-related .gem-c-step-nav-related__heading .govuk-link"

    expected = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "1" },
      "index_total": "1",
      "section": "Part of",
    }

    assert_select "#{this_link}[data-ga4-link='#{expected.to_json}']"
  end

  it "does not add GA4 data attributes when ga4_tracking is false" do
    render_component(links: one_link, ga4_tracking: false)

    this_link = ".gem-c-step-nav-related .gem-c-step-nav-related__heading .govuk-link"

    expected = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "1" },
      "index_total": "1",
      "section": "Part of",
    }

    assert_select "#{this_link}[data-ga4-link='#{expected.to_json}']", false
  end

  it "adds GA4 data attributes on multiple links when ga4_tracking is true" do
    render_component(links: two_links, ga4_tracking: true)

    link_one = ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link1']"
    link_two = ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link2']"

    expected_one = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "1" },
      "index_total": "2",
      "section": "Part of",
    }

    expected_two = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "2" },
      "index_total": "2",
      "section": "Part of",
    }

    assert_select "#{link_one}[data-ga4-link='#{expected_one.to_json}']"
    assert_select "#{link_two}[data-ga4-link='#{expected_two.to_json}']"
  end

  it "does not add GA4 data attributes on multiple links when ga4_tracking is false" do
    render_component(links: two_links, ga4_tracking: false)

    link_one = ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link1']"
    link_two = ".gem-c-step-nav-related .gem-c-step-nav-related__links .govuk-link[href='/link2']"

    expected_one = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "1" },
      "index_total": "2",
      "section": "Part of",
    }

    expected_two = {
      "event_name": "navigation",
      "type": "related content",
      "index": { "index_link": "2" },
      "index_total": "2",
      "section": "Part of",
    }

    assert_select "#{link_one}[data-ga4-link='#{expected_one.to_json}']", false
    assert_select "#{link_two}[data-ga4-link='#{expected_two.to_json}']", false
  end
end
