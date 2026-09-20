# Hotwire & Turbo (Turbo 7 & Turbo 8)

## Turbo Drive

Turbo Drive automatically converts link clicks and form submissions into AJAX requests:

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: "Article created!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

```erb
<!-- app/views/articles/new.html.erb -->
<%= form_with model: @article do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body %>
  <%= f.submit %>
<% end %>
```

## Turbo Frames

Turbo Frames enable scoped page updates. Always pass the model record directly to `turbo_frame_tag` rather than manually interpolating string IDs:

```erb
<!-- app/views/articles/show.html.erb -->
<%= turbo_frame_tag @article do %>
  <h1><%= @article.title %></h1>
  <p><%= @article.body %></p>
  <%= link_to "Edit", edit_article_path(@article) %>
<% end %>

<!-- app/views/articles/edit.html.erb -->
<%= turbo_frame_tag @article do %>
  <%= form_with model: @article do |f| %>
    <%= f.text_field :title %>
    <%= f.text_area :body %>
    <%= f.submit %>
  <% end %>
<% end %>
```

Lazy loading with Turbo Frames:

```erb
<%= turbo_frame_tag "expensive_content", src: expensive_content_path, loading: :lazy %>
```

## Turbo Streams

Real-time partial updates via Turbo Streams:

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @comment = @article.comments.create(comment_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @article }
    end
  end
end
```

```erb
<!-- app/views/comments/create.turbo_stream.erb -->
<%= turbo_stream.append "comments" do %>
  <%= render @comment %>
<% end %>

<%= turbo_stream.update "comment_form" do %>
  <%= render "comments/form", comment: Comment.new %>
<% end %>
```

### Model Broadcasting with Action Cable

Declarative model broadcasting:

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :article

  # Concise declarative broadcast (Turbo Rails standard):
  broadcasts_to :article, inserts_by: :append, target: "comments"

  # Or individual callbacks when customized rendering or target logic is required:
  # after_create_commit -> { broadcast_append_to article, target: "comments" }
  # after_update_commit -> { broadcast_replace_to article }
  # after_destroy_commit -> { broadcast_remove_to article }
end
```

```erb
<!-- app/views/articles/show.html.erb -->
<%= turbo_stream_from @article %>

<div id="comments">
  <%= render @article.comments %>
</div>
```

## Turbo 8 Page Refresh & Morphing

Turbo 8 introduces page refreshes with Idiomorph DOM morphing, reducing the need for manual Turbo Stream partials:

```erb
<!-- app/views/layouts/application.html.erb -->
<head>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
  <%= yield :head %>
</head>
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  # Triggers automatic morph refresh on subscribers
  broadcasts_refreshes
end
```

## Stimulus Controllers

JavaScript sprinkles with Stimulus:

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
```

```erb
<!-- app/views/shared/_dropdown.html.erb -->
<div data-controller="dropdown" data-action="click@window->dropdown#hide">
  <button data-action="dropdown#toggle">Menu</button>
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Item 1</a>
    <a href="#">Item 2</a>
  </div>
</div>
```

## Form Validation with Stimulus

```javascript
// app/javascript/controllers/form_validator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  validate() {
    const value = this.inputTarget.value

    if (value.length < 3) {
      this.errorTarget.textContent = "Must be at least 3 characters"
      this.inputTarget.classList.add("border-red-500")
    } else {
      this.errorTarget.textContent = ""
      this.inputTarget.classList.remove("border-red-500")
    }
  }
}
```

## Turbo Stream Actions

Core stream actions:

```ruby
# append, prepend, replace, update, remove, before, after
turbo_stream.append "target_id", partial: "item", locals: { item: @item }
turbo_stream.prepend "target_id", html: content
turbo_stream.replace "target_id", @item
turbo_stream.update "target_id", html: "<p>Updated</p>"
turbo_stream.remove "target_id"
turbo_stream.before "target_id", partial: "item"
turbo_stream.after "target_id", partial: "item"
```

## Best Practices

- Pass model records directly to `turbo_frame_tag` (`turbo_frame_tag @article`), avoiding manual string ID concatenation
- Use Turbo 8 morphing (`turbo_refreshes_with method: :morph`) for low-boilerplate real-time updates
- Use lazy loading for off-screen frames
- Debounce Stimulus actions for search and filter inputs
- Cache Turbo Stream partials when rendering high-frequency collections
