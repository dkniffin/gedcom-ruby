[![Build Status](https://travis-ci.org/dkniffin/gedcom-ruby.svg?branch=master)](https://travis-ci.org/dkniffin/gedcom-ruby)
[![Code Climate](https://codeclimate.com/github/dkniffin/gedcom-ruby/badges/gpa.svg)](https://codeclimate.com/github/dkniffin/gedcom-ruby)

GEDCOM-Ruby
-----------

This is a module for the Ruby language that defines a callback GEDCOM parser.
It does not do any validation of a GEDCOM file, but, using application-defined
callback hooks, can traverse any well-formed GEDCOM.

The module also includes a sophisticated date parser that can parse any
standard GEDCOM-formatted date (see the GEDCOM spec for details on the
format).


Installation
------------

On the command line:

````ruby
gem install gedcom_ruby
````
Or add this to your Gemfile
````ruby
gem 'gedcom_ruby', '~> 0.3.0'
````

Usage
-----

To use this module in your own programs, you can either inherit from
the GEDCOM::Parser class (in which case the initialize method should
call 'super' before doing anything else), or you can instantiate the
GEDCOM::Parser class directly.

Either way, the before() and after() methods should then be used to
register callbacks for specified contexts.  A "context" is simply an
array of strings, where each element of the array specifies a GEDCOM
row type.  For example:

````
  [ "INDI" ] -> this context defines a row on which an individual is
  introduced.
  [ "INDI", "BIRT", "DATE" ] -> this context defines the birthdate of
  an individual.
````

Callbacks are registered using a proc, a method name, or a block:

````
  before( context, proc )
  after( context, proc )

  before( context, :method )
  after( context, :method )

  before( context ) do ... end
  after( context ) do ... end
````

The 'before' handler is called as soon as the context is recognized,
before anything else is done.  The 'after' handler is called when the
given context is about to expire.  For example, if the context were
["INDI"], the before handler would be called as soon as a row of type
'INDI' at level 0 was encountered, while the after handler would be
called as soon as another row of level 0 was encountered, before that
row's before handler was invoked.  This allows you do perform
initialization and commit operations.

Callbacks should take a single parameter, which will be the data portion of each row:

````
  def callbackFunction( data, cookie, parm )
    ...
  end
````

To parse a file, simply call the parser's 'parse' method, passing the
name of the file to parse.  The 'parse' method will take a filename,
or an IO instance.


API Reference
-------------
````
  module GEDCOM

    class Parser

      def initialize( &block )
        :: Constructor.  Can optionally be called with a block, which is
        used to define the before and after callbacks.

      def before( context, proc=nil, &block )
        :: Registers the given proc or block to be called
        as soon as the given context is recognized.

      def after( context, proc=nil, &block )
        :: Registers the given proc or block to be called as soon as
        the given context expires.

      def auto_concat= boolean
        :: Sets the auto-concatenation mode (defaults to true/on).
        When auto-concatenation is enabled, any CONT tags in the input
        will be appended to the previous tag, and the 'after' callback
        for that tag will include all of the concatenated data.  No
        callbacks for CONT tags will be made in this case.  When
        auto-concatenation is disabled, each CONT tag will be treated
        as normal, with before and after callbacks.

      def parse( file_or_io )
        :: Opens and parses the file with the given name, or an existing
        IO instance, invoking callbacks as the registered contexts are
        recognized.

      def context
        :: Gives the current context during the parse.  Intended to be
        used by callbacks to determine the context when the same
        callback method is used to handle multiple contexts.


    class Date

      def initialize( date_str, calendar=DateType::DEFAULT )
      def initialize( date_str, calendar=DateType::DEFAULT ) { |err_msg| ... }
        :: Creates a new GEDCOM Date object from the given string.  In the first form, if
           the string does not define a valid date, a GEDCOM::DateFormatException is raised.
           In the second form, an exception is not raised, but the given block is called
           when there is an error.  Also, in the second form, a Date object is still returned,
           but it will contain nothing except the string that was passed to it.

      def Date.safe_new( date_str )
        :: Creates a new GEDCOM Date object, but never throws a DateFormatException.

      def format
        :: Returns one of the following constants, indicating what the format of the date is:
             NONE, ABOUT, CALCULATED, ESTIMATED, BEFORE, AFTER, BETWEEN, FROM, TO, FROMTO,
             INTERPRETED, CHILD, CLEARED, COMPLETED, INFANT, PRE1970, QUALIFIED, STILLBORN,
             SUBMITTED, UNCLEARED, BIC, DNS, DNSCAN, DEAD

      def first
        :: Returns a GEDCOM::DatePart object that defines the first part of the date.

      def last
        :: Returns a GEDCOM::DatePart object that defines the last part of the date.  This
           will only be valid for a date format of BETWEEN or FROMTO (indicating a range
           of dates).

      def to_s
        :: Returns the date formatted as a string.

      def is_date?
        :: Returns true if the Date object defines a date, but returns false if it
           defines some non-date value (ie, there was an error parsing the date, or if the
           date format is one of CHILD, CLEARED, COMPLETED, INFANT, PRE1970, QUALIFIED,
           STILLBORN, SUBMITTED, UNCLEARED, BIC, DNS, DNSCAN, or DEAD).

      def is_range?
        :: Returns true if the Date object defines a date range (ie, format is either
           BETWEEN or FROMTO).  If this is true, then Date.last will return the end of
           the range.

      def <=>( date )
        :: Compares this date with the parameter, and returns -1, 0, or 1.


    class DatePart

      def calendar
        :: Returns the calendar that was used to represent the given date.  Valid values
           are DateType::GREGORIAN, DateType::JULIAN, DateType::HEBREW, DateType::FRENCH,
           DateType::FUTURE, DateType::UNKNOWN, and DateType::DEFAULT.

      def compliance
        :: Returns the compliance of the date (ie, whether it is a valid date or not).
           Valid values are DatePart::NONE (meaning it is a valid date), DatePart::PHRASE
           (meaning the date contains a phrase, not a date) and DatePart::NONSTANDARD
           (meaning there was an error parsing the date).

      def phrase
        :: If the compliance is DatePart::PHRASE, this will return the phrase value.
           Otherwise, this will raise a DateFormatException.

      def has_day?
        :: Returns true if the date contains a day value.

      def has_month?
        :: Returns true if the date contains a month value.

      def has_year?
        :: Returns true if the date contains a year value.

      def has_year_span?
        :: Returns true if the date contains a span of years (valid only for
           DateType::GREGORIAN calendars).  This means the date was formatted
           like '25 Jul 1974-1980'.

      def day
        :: Returns the day portion of the date, if it has a day.  If it does not
           have a day, a DateFormatException is raised.

      def month
        :: Returns the month portion of the date, if it has a month.  If it does not
           have a month, a DateFormatException is raised.  (The month value will
           be an integer, with 1 being the first month of the year.)

      def year
        :: Returns the year portion of the date, if it has a year.  If it does not
           have a year, a DateFormatException is raised.

      def to_year
        :: Returns the second year portion of the date, if it has a year span.  If
           it does not contain a year span, a DateFormatException is raised.

      def epoch
        :: Returns either "BC" or "AD", as appropriate.

      def to_s
        :: Converts the DatePart object to a string.

      def <=>( date_part )
        :: Compares this date_part with the parameter, and returns -1, 0, or 1.
````

Feedback & Contributions
------------
If you encounter an issue with this gem, please report it in the issue tracker.

Code contributions in the form of pull requests are always welcome, however **All contributions must include relevant test cases.**
