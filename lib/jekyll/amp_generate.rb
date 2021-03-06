module Jekyll
  # Defines the base class of AMP posts
  class AmpPost < Page
    def initialize(site, base, dir, post)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'amp.html')
      self.content               = post.content
      self.data['body']          = (Liquid::Template.parse post.content).render site.site_payload

      # Merge all data from post so that keys from self.data have higher priority
      self.data = post.data.merge(self.data)

      # Remove non needed keys from data
      # Excerpt will cause an error if kept
      self.data.delete('excerpt')

      self.data['canonical_url'] = post.url
      self.data['related_posts'] = post.related_posts

    end
  end

  # Defines the base class of AMP features
  class AmpFeature < Page
    def initialize(site, base, dir, feature)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'amp_features.html')
      self.content               = feature.content
      self.data['body']          = (Liquid::Template.parse feature.content).render site.site_payload

      # Merge all data from post so that keys from self.data have higher priority
      self.data = feature.data.merge(self.data)

      # Remove non needed keys from data
      # Excerpt will cause an error if kept
      self.data.delete('excerpt')

      self.data['canonical_url'] = feature.url
      self.data['related_posts'] = feature.related_posts

    end
  end

  # Generates a new AMP post for each existing post
  class AmpGenerator < Generator
    priority :low
    def generate(site)
      dir = site.config['ampdir'] || 'amp'
      site.posts.docs.each do |post|
        next if post.data['skip_amp'] == true || site.incremental? == true
        site.pages << AmpPost.new(site, site.source, File.join(dir, post.id), post)
      end
      dir = site.config['ampdir'] || 'amp'
      site.collections["features"].docs.each do |feature|
        next if feature.data['skip_amp'] == true || site.incremental? == true
        site.pages << AmpFeature.new(site, site.source, File.join(dir, feature.id), feature)
      end
    end
  end
end
