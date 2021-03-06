# vim: ft=cucumber fileencoding=utf-8 sts=4 sw=4 et:

Feature: Special qute:// pages

    # :help

    Scenario: :help without topic
        When I run :tab-only
        And I run :help
        And I wait until qute://help/index.html is loaded
        Then the following tabs should be open:
            - qute://help/index.html (active)

    Scenario: :help with invalid topic
        When I run :help foo
        Then the error "Invalid help topic foo!" should be shown

    Scenario: :help with command
        When the documentation is up to date
        And I run :tab-only
        And I run :help :back
        And I wait until qute://help/commands.html#back is loaded
        Then the following tabs should be open:
            - qute://help/commands.html#back (active)

    Scenario: :help with invalid command
        When I run :help :foo
        Then the error "Invalid command foo!" should be shown

    Scenario: :help with setting
        When the documentation is up to date
        And I run :tab-only
        And I run :help editor.command
        And I wait until qute://help/settings.html#editor.command is loaded
        Then the following tabs should be open:
            - qute://help/settings.html#editor.command (active)

    Scenario: :help with -t
        When I open about:blank
        And I run :tab-only
        And I run :help -t
        And I wait until qute://help/index.html is loaded
        Then the following tabs should be open:
            - about:blank
            - qute://help/index.html (active)

    # https://github.com/qutebrowser/qutebrowser/issues/2513
    Scenario: Opening link with qute:help
        When the documentation is up to date
        And I run :tab-only
        And I open qute:help without waiting
        And I wait for "Changing title for idx 0 to 'qutebrowser help'" in the log
        And I hint with args "links normal" and follow a
        Then qute://help/quickstart.html should be loaded

    # :history

    Scenario: :history without arguments
        When I run :tab-only
        And I run :history
        And I wait until qute://history/ is loaded
        Then the following tabs should be open:
            - qute://history/ (active)

    Scenario: :history with -t
        When I open about:blank
        And I run :tab-only
        And I run :history -t
        And I wait until qute://history/ is loaded
        Then the following tabs should be open:
            - about:blank
            - qute://history/ (active)

    # qute://settings

    Scenario: Focusing input fields in qute://settings and entering valid value
        When I set ignore_case to never
        And I open qute://settings
        # scroll to the right - the table does not fit in the default screen
        And I run :scroll-to-perc -x 100
        And I run :jseval document.getElementById('input-ignore_case').value = ''
        And I run :click-element id input-ignore_case
        And I wait for "Entering mode KeyMode.insert *" in the log
        And I press the keys "always"
        And I press the key "<Escape>"
        # an explicit Tab to unfocus the input field seems to stabilize the tests
        And I press the key "<Tab>"
        And I wait for "Config option changed: ignore_case *" in the log
        Then the option ignore_case should be set to always

    Scenario: Focusing input fields in qute://settings and entering invalid value
        When I open qute://settings
        # scroll to the right - the table does not fit in the default screen
        And I run :scroll-to-perc -x 100
        And I run :jseval document.getElementById('input-ignore_case').value = ''
        And I run :click-element id input-ignore_case
        And I wait for "Entering mode KeyMode.insert *" in the log
        And I press the keys "foo"
        And I press the key "<Escape>"
        # an explicit Tab to unfocus the input field seems to stabilize the tests
        And I press the key "<Tab>"
        Then "Invalid value 'foo' *" should be logged

    # pdfjs support

    @qtwebengine_skip: pdfjs is not implemented yet
    Scenario: pdfjs is used for pdf files
        Given pdfjs is available
        When I set content.pdfjs to true
        And I open data/misc/test.pdf
        Then the javascript message "PDF * [*] (PDF.js: *)" should be logged

    @qtwebengine_todo: pdfjs is not implemented yet
    Scenario: pdfjs is not used when disabled
        When I set content.pdfjs to false
        And I set downloads.location.prompt to false
        And I open data/misc/test.pdf
        Then "Download test.pdf finished" should be logged

    @qtwebengine_skip: pdfjs is not implemented yet
    Scenario: Downloading a pdf via pdf.js button (issue 1214)
        Given pdfjs is available
        # WORKAROUND to prevent the "Painter ended with 2 saved states" warning
        # Might be related to https://bugreports.qt.io/browse/QTBUG-13524 and
        # a weird interaction with the previous test.
        And I have a fresh instance
        When I set content.pdfjs to true
        And I set downloads.location.suggestion to filename
        And I set downloads.location.prompt to true
        And I open data/misc/test.pdf
        And I wait for "[qute://pdfjs/*] PDF * (PDF.js: *)" in the log
        And I run :jseval document.getElementById("download").click()
        And I wait for "Asking question <qutebrowser.utils.usertypes.Question default='test.pdf' mode=<PromptMode.download: 5> text=* title='Save file to:'>, *" in the log
        And I run :leave-mode
        Then no crash should happen

    # :pyeval

    Scenario: Running :pyeval
        When I run :debug-pyeval 1+1
        And I wait until qute://pyeval is loaded
        Then the page should contain the plaintext "2"

    Scenario: Causing exception in :pyeval
        When I run :debug-pyeval 1/0
        And I wait until qute://pyeval is loaded
        Then the page should contain the plaintext "ZeroDivisionError"

    Scenario: Running :pyeval with --quiet
        When I run :debug-pyeval --quiet 1+1
        Then "pyeval output: 2" should be logged

    ## :messages

    Scenario: :messages without level
        When I run :message-error the-error-message
        And I run :message-warning the-warning-message
        And I run :message-info the-info-message
        And I run :messages
        Then qute://log?level=info should be loaded
        And the error "the-error-message" should be shown
        And the warning "the-warning-message" should be shown
        And the page should contain the plaintext "the-error-message"
        And the page should contain the plaintext "the-warning-message"
        And the page should contain the plaintext "the-info-message"

    Scenario: Showing messages of type 'warning' or greater
        When I run :message-error the-error-message
        And I run :message-warning the-warning-message
        And I run :message-info the-info-message
        And I run :messages warning
        Then qute://log?level=warning should be loaded
        And the error "the-error-message" should be shown
        And the warning "the-warning-message" should be shown
        And the page should contain the plaintext "the-error-message"
        And the page should contain the plaintext "the-warning-message"
        And the page should not contain the plaintext "the-info-message"

    Scenario: Showing messages of type 'info' or greater
        When I run :message-error the-error-message
        And I run :message-warning the-warning-message
        And I run :message-info the-info-message
        And I run :messages info
        Then qute://log?level=info should be loaded
        And the error "the-error-message" should be shown
        And the warning "the-warning-message" should be shown
        And the page should contain the plaintext "the-error-message"
        And the page should contain the plaintext "the-warning-message"
        And the page should contain the plaintext "the-info-message"

    @qtwebengine_flaky
    Scenario: Showing messages of an invalid level
        When I run :messages cataclysmic
        Then the error "Invalid log level cataclysmic!" should be shown

    Scenario: Using qute://log directly
        When I open qute://log without waiting
        # With Qt 5.9, we don't get a loaded message?
        And I wait for "Changing title for idx * to 'log'" in the log
        Then no crash should happen

    Scenario: Using qute://plainlog directly
        When I open qute://plainlog
        Then no crash should happen

    # :version

    Scenario: Open qute://version
        When I open qute://version
        Then the page should contain the plaintext "Version info"
