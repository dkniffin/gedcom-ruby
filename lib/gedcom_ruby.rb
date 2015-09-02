# -------------------------------------------------------------------------
# gedcom.rb -- core module definition of GEDCOM-Ruby interface
# Copyright (C) 2003 Jamis Buck (jgb3@email.byu.edu)
# -------------------------------------------------------------------------
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------

#require '_gedcom'
require 'gedcom_ruby/date'
require 'stringio'
require 'byebug'

module GEDCOM

  class Parser
    attr_accessor :auto_concat
    attr_reader :callbacks
    ANY = [:any]

    def initialize(&block)
      @callbacks = {
        :before => {},
        :after  => {}
      }

      @context_stack = []
      @data_stack = []
      @current_level = -1

      @auto_concat = true

      instance_eval(&block) if block_given?

      after_initialize
    end

    def after_initialize
      # Template
    end

    def before(tags, callback=nil, &block)
      tags = [tags].flatten
      callback = check_proc_or_block(callback, &block)

      @callbacks[:before][tags] = default_empty(@callbacks[:before][tags])
      @callbacks[:before][tags].push(callback)
    end

    def after(tags, callback=nil, &block)
      tags = [tags].flatten
      callback = check_proc_or_block(callback, &block)

      @callbacks[:after][tags] = default_empty(@callbacks[:after][tags])
      @callbacks[:after][tags].push(callback)
    end

    def parse(file)
      case file
      when String
        if file =~ /\n/mo
          parse_string(file)
        else
          parse_file(file)
        end
      when IO
        parse_io(file)
      else
        raise ArgumentError.new("requires a String or IO")
      end
    end

    def context
      @context_stack
    end


    protected

    def default_empty(arr)
      arr || []
    end

    def check_proc_or_block(proc, &block)
      unless proc or block_given?
        raise ArgumentError.new("proc or block required")
      end
      proc = method(proc) if proc.kind_of? Symbol
      proc ||= Proc.new(&block)
    end

    def parse_file(file)
      File.open(file) do |io|
        parse_io(io)
      end
    end

    def parse_string(str)
      parse_io(StringIO.new(str))
    end

    def parse_io(io)
      io.each_line do |line|
        line = line.rstrip!
        next if line.empty?
        level, tag, rest = line.match(/^(\d) (\S+) ?(.*)$/).captures
        level = level.to_i

        if (tag == 'CONT' || tag == 'CONC') and @auto_concat
          concat_data(tag, rest)
          next
        end

        unwind_to(level)

        tag, rest = rest, tag if tag =~ /@.*@/

        @context_stack.push(tag)
        @data_stack.push(rest)
        @current_level = level

        do_callbacks(:before, @context_stack, rest)
      end
      unwind_to(-1)
    end

    def unwind_to(level)
      while @current_level >= level
        do_callbacks(:after, @context_stack, @data_stack.last)
        @context_stack.pop
        @data_stack.pop
        @current_level -= 1
      end
    end

    def concat_data(tag, rest)
      rest = rest || "" # Handle nil case
      @data_stack[-1] = case
      when @data_stack.last.empty?       then rest
      when @context_stack.last == 'BLOB' then "#{@data_stack.last}#{rest}"
      when tag == 'CONT'                 then "#{@data_stack.last}\n#{rest}"
      when tag == 'CONC'                 then "#{@data_stack.last}#{rest}"
      end
    end

    def do_callbacks(context_sym, tags, data)
      return if tags == []
      tag_cbs = default_empty(@callbacks[context_sym][tags])
      any_cbs = default_empty(@callbacks[context_sym][ANY])
      relevant_callbacks = tag_cbs + any_cbs
      relevant_callbacks.each do |callback|
        callback.call(data)
      end
    end
  end #/ Parser

end #/ GEDCOM
