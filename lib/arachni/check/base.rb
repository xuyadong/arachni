=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

module Arachni

require Options.paths.lib + 'check/auditor'

module Check

# Base check class to be extended by all checks.
#
# Defines basic structure and provides utilities to checks.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
# @abstract
class Base < Component::Base
    include Auditor

    # @param  [Page]        page
    # @param  [Framework]  framework
    def initialize( page, framework )
        super
    end

    # OPTIONAL
    #
    # It provides you with a way to setup your check's data and methods.
    #
    # @abstract
    def prepare
    end

    # REQUIRED
    #
    # This is used to deliver the check's payload whatever it may be.
    #
    # @abstract
    def run
    end

    # OPTIONAL
    #
    # This is called after {#run} has finished executing,
    #
    # @abstract
    def clean_up
    end

    # Provides access to the plugin manager
    #
    # You can use it to gain access to the instances of running plugins like so:
    #
    #    p plugins.get( 'profiler' )
    #    # => #<Thread:0x000000025b2ff0 sleep>
    #
    #    p plugins.get( 'profiler' )[:instance]
    #    # => #<Arachni::Plugins::Profiler>
    #
    # @return   [Arachni::Plugin::Manager]
    def plugins
        framework.plugins if framework
    end

    # @return   [Arachni::Session]
    def session
        framework.session if framework
    end

    # @return   [Arachni::BrowserCluster]
    def browser_cluster
        framework.browser_cluster if framework
    end

    def preferred
        self.class.preferred
    end

    # REQUIRED
    #
    # Provides information about the check.
    # Don't take this lightly and don't ommit any of the info.
    #
    # @abstract
    def self.info
        {
            name:        'Base check abstract class',
            description: %q{Provides an abstract class the check should implement.},
            #
            # Arachni needs to know what elements the check plans to audit
            # before invoking it.
            # If a page doesn't have any of those elements
            # there's no point in instantiating the check.
            #
            # If you want the check to run no-matter what, leave the array
            # empty.
            #
            # elements: [
            #     Element::Form,
            #     Element::Link
            #     Element::Cookie
            #     Element::Header
            # ],
            elements:    [],
            author:      'Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>',
            version:     '0.1',
            references:  {
                'Title' => 'http://ref.url'
            },

            issue:       {
                name:           %q{Serious issue},
                description:    %q{This issue is a serious issue and you
                    should consider it seriously},
                # CWE ID number
                cwe:            0,
                #
                # Severity can be:
                #
                # Severity::HIGH
                # Severity::MEDIUM
                # Severity::LOW
                # Severity::INFORMATIONAL
                #
                severity:        Severity::HIGH,
                remedy_guidance: %q{Paint it blue and throw it in the sea.},
                remedy_code:     %q{sudo rm -rf /}
            }
        }
    end

    class <<self

        # @return   [Bool]
        #   `true` if the check can benefit from knowing the platform beforehand,
        #   `false` otherwise.
        # @see .platforms
        def has_platforms?
            platforms.any?
        end

        # @return   [Array<Symbol>] Targeted platforms.
        # @see .info
        def platforms
            [info[:platforms]].flatten.compact
        end

        # @return   [Array<Symbol>] Targeted element types.
        # @see .info
        def elements
            [info[:elements]].flatten.compact
        end

        # Schedules self to be run *after* the specified checks and prevents
        # auditing elements that have been previously logged by any of these checks.
        #
        # @return   [Array] Check names.
        def prefer( *args )
            @preferred = args.flatten.compact
        end

        # @return   [Array]
        #   Names of checks which should be preferred over this one.
        #
        # @see #prefer
        def preferred
            @preferred ||= []
        end
    end

end
end
end
