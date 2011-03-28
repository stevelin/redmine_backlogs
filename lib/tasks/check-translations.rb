#!/usr/bin/env ruby

require 'yaml'

webdir = File.join(File.dirname(__FILE__), '..', '..', '..', 'www.redminebacklogs.net')
$logfile = nil
if File.directory? webdir
    $logfile = File.open(File.join(webdir, '_posts', 'en', '1992-01-01-translations.textile'), 'w')
end

def log(s)
    puts s
    $logfile.puts(s) if $logfile
end

langdir = File.join(File.dirname(__FILE__), '..', '..', 'config', 'locales')

template_file = "#{langdir}/en.yml"
template = YAML::load_file(template_file)['en']

log """---
title: Translations
layout: default
categories: en
---
h1. Translations

h2. en

serves as a base for all other translations

"""

Dir.glob("#{langdir}/*.yml").sort.each {|lang_file|
  next if lang_file == template_file


  lang = YAML::load_file(lang_file)
  l = lang.keys[0]


  missing = []
  obsolete = []
  varstyle = []

  template.each_pair {|key, txt|
    missing << key if ! lang[l][key]
  }

  lang[l].keys.each {|key|
    if !template[key]
      obsolete << key
    elsif lang[l][key].include?('{{')
      varstyle << key
    end
  }

  if missing.size > 0 || obsolete.size > 0
    columns = 2
    log "h2. #{l}: needs update\n\n"
    [[missing, 'Missing'], [obsolete, 'Obsolete'], [varstyle, 'Old-style variable substitution']].each {|cat|
        keys, title = *cat
        next if keys.size == 0

        log "*#{title}*\n\n"
        keys.sort!
        while keys.size > 0
            row = (keys.shift(columns) + ['', ''])[0..columns-1]
            log "|" + row.join("|") + "|\n"
        end
        log "\n"
    }
  else
    log "h2. #{l}\n\n"
  end
}


$logfile.close if $logfile
