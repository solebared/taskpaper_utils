# TaskpaperUtils
Simple ruby library for parsing and working with [TaskPaper] formatted documents.

The [TaskPaper] format is defined by [Hog Bay Software](http://www.hogbaysoftware.com/) for use in their excellent [TaskPaper] OS X app.  It is designed to be human readable and universally portable as plain text.

This library:

- parses a [TaskPaper] document,
- provides an object graph of projects, tasks and notes contained therein,
- allows changes to be saved back to a [TaskPaper] file,
- does _not_ interact with the [TaskPaper] app itself.

## Installation
I haven't published this as a gem yet, so...

Either use `bundler`:

    # add this to your Gemfile
    gem 'taskpaper_utils', git: 'git://github.com/exbinary/taskpaper_utils'
    # then:
    bundle install

Or build the gem yourself:

    git clone https://github.com/exbinary/taskpaper_utils
    gem build taskpaper_utils/taskpaper_utils.gemspec
    gem install taskpaper_utils-<version>.gem

## Usage

The primary entry point is:

    TaskpaperUtils.parse('path/to/file.taskpaper')
    
This will return an instance of `Document` which contains `Project`, `Task`, and `Note` instances nested appropriately.

To reserialize the object graph back to file, use:

    TaskpaperUtils.save(document, 'path/to/new/file.taskpaper') 

_More usage examples to come..._

## Status & Roadmap
Currently, this is mostly a spike (pre-alpha).
The public interface hasn't settled down yet.

A loose roadmap:

- Parse tags
- Evolve API for adding, removing and modifying entries
- Evolve search and filtering API
- ... ?

## Contributing
At this early stage i'm mostly in need of use-cases to guide API and design priorities.  I use this library in a couple of scripts but those workflows are pretty personalized so i'd appreciate input on what other uses you might envision for taskpaper_utils.

Of course i always value [questions, feedback, code review](https://github.com/exbinary), and [bug reports](https://github.com/exbinary/taskpaper_utils/issues).

## Resources

* A detailed description (and example) of the [TaskPaper] syntax can be found in [exemplar.taskpaper](spec/integration/exemplar.taskpaper)
* The TaskPaper [wiki](http://www.hogbaysoftware.com/wiki/TaskPaper), including a list of related tools.
* An alternative ruby library named [taskpaper-tools](https://github.com/thiagoa/taskpaper-tools), also in early development as of this writing.

---

[TaskPaper]: http://www.hogbaysoftware.com/products/taskpaper

