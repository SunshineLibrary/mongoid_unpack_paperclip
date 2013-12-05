mongoid_unpack_paperclip
========================
给含有paperclip的Mongoid 支持解压缩包和清理的封装。


Usage
------------------------

```ruby
class ExampleModel
  include Mongoid::Paperclip
  include Mongoid::UnpackPaperclip

  def process
    self.unpack_paperclip do
      ... # your implementation
    end
  end
end
```
