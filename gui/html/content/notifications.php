<?php
// Verify user logged in, redirect to index if not
session_start();
require '/var/www/VSW-GUI-CONFIG';
if (!isset($_SESSION['login']) || $_SESSION['login'] != $hash) {
  header("Location: /index.php");
  exit();
}
?>
<script type="text/javascript">
	$(function() {
		$(".hide-to-fade").fadeIn(300);
	});
</script>

<?php


/**
 * RSS for PHP - small and easy-to-use library for consuming an RSS Feed
 *
 * @copyright  Copyright (c) 2008 David Grudl
 * @license    New BSD License
 * @version    1.5
 */
class Feed
{
    /** @var int */
    public static $cacheExpire = '1 day';

    /** @var string */
    public static $cacheDir;

    /** @var string */
    public static $userAgent = 'FeedFetcher-Google';

    /** @var SimpleXMLElement */
    protected $xml;


    /**
     * Loads RSS or Atom feed.
     * @param  string
     * @param  string
     * @param  string
     * @return Feed
     * @throws FeedException
     */
    public static function load($url, $user = null, $pass = null)
    {
        $xml = self::loadXml($url, $user, $pass);
        if ($xml->channel) {
            return self::fromRss($xml);
        } else {
            return self::fromAtom($xml);
        }
    }


    /**
     * Loads RSS feed.
     * @param  string  RSS feed URL
     * @param  string  optional user name
     * @param  string  optional password
     * @return Feed
     * @throws FeedException
     */
    public static function loadRss($url, $user = null, $pass = null)
    {
        return self::fromRss(self::loadXml($url, $user, $pass));
    }


    /**
     * Loads Atom feed.
     * @param  string  Atom feed URL
     * @param  string  optional user name
     * @param  string  optional password
     * @return Feed
     * @throws FeedException
     */
    public static function loadAtom($url, $user = null, $pass = null)
    {
        return self::fromAtom(self::loadXml($url, $user, $pass));
    }


    private static function fromRss(SimpleXMLElement $xml)
    {
        if (!$xml->channel) {
            throw new FeedException('Invalid feed.');
        }

        self::adjustNamespaces($xml);

        foreach ($xml->channel->item as $item) {
            // converts namespaces to dotted tags
            self::adjustNamespaces($item);

            // generate 'url' & 'timestamp' tags
            $item->url = (string) $item->link;
            if (isset($item->{'dc:date'})) {
                $item->timestamp = strtotime($item->{'dc:date'});
            } elseif (isset($item->pubDate)) {
                $item->timestamp = strtotime($item->pubDate);
            }
        }
        $feed = new self;
        $feed->xml = $xml->channel;
        return $feed;
    }


    private static function fromAtom(SimpleXMLElement $xml)
    {
        if (!in_array('http://www.w3.org/2005/Atom', $xml->getDocNamespaces(), true)
            && !in_array('http://purl.org/atom/ns#', $xml->getDocNamespaces(), true)
        ) {
            throw new FeedException('Invalid feed.');
        }

        // generate 'url' & 'timestamp' tags
        foreach ($xml->entry as $entry) {
            $entry->url = (string) $entry->link['href'];
            $entry->timestamp = strtotime($entry->updated);
        }
        $feed = new self;
        $feed->xml = $xml;
        return $feed;
    }


    /**
     * Returns property value. Do not call directly.
     * @param  string  tag name
     * @return SimpleXMLElement
     */
    public function __get($name)
    {
        return $this->xml->{$name};
    }


    /**
     * Sets value of a property. Do not call directly.
     * @param  string  property name
     * @param  mixed   property value
     * @return void
     */
    public function __set($name, $value)
    {
        throw new Exception("Cannot assign to a read-only property '$name'.");
    }


    /**
     * Converts a SimpleXMLElement into an array.
     * @param  SimpleXMLElement
     * @return array
     */
    public function toArray(SimpleXMLElement $xml = null)
    {
        if ($xml === null) {
            $xml = $this->xml;
        }

        if (!$xml->children()) {
            return (string) $xml;
        }

        $arr = [];
        foreach ($xml->children() as $tag => $child) {
            if (count($xml->$tag) === 1) {
                $arr[$tag] = $this->toArray($child);
            } else {
                $arr[$tag][] = $this->toArray($child);
            }
        }

        return $arr;
    }


    /**
     * Load XML from cache or HTTP.
     * @param  string
     * @param  string
     * @param  string
     * @return SimpleXMLElement
     * @throws FeedException
     */
    private static function loadXml($url, $user, $pass)
    {
        $e = self::$cacheExpire;
        $cacheFile = self::$cacheDir . '/feed.' . md5(serialize(func_get_args())) . '.xml';

        if (self::$cacheDir
            && (time() - @filemtime($cacheFile) <= (is_string($e) ? strtotime($e) - time() : $e))
            && $data = @file_get_contents($cacheFile)
        ) {
            // ok
        } elseif ($data = trim(self::httpRequest($url, $user, $pass))) {
            if (self::$cacheDir) {
                file_put_contents($cacheFile, $data);
            }
        } elseif (self::$cacheDir && $data = @file_get_contents($cacheFile)) {
            // ok
        } else {
            throw new FeedException('Cannot load feed.');
        }

        return new SimpleXMLElement($data, LIBXML_NOWARNING | LIBXML_NOERROR | LIBXML_NOCDATA);
    }


    /**
     * Process HTTP request.
     * @param  string
     * @param  string
     * @param  string
     * @return string|false
     * @throws FeedException
     */
    private static function httpRequest($url, $user, $pass)
    {
        if (extension_loaded('curl')) {
            $curl = curl_init();
            curl_setopt($curl, CURLOPT_URL, $url);
            if ($user !== null || $pass !== null) {
                curl_setopt($curl, CURLOPT_USERPWD, "$user:$pass");
            }
            curl_setopt($curl, CURLOPT_USERAGENT, self::$userAgent); // some feeds require a user agent
            curl_setopt($curl, CURLOPT_HEADER, false);
            curl_setopt($curl, CURLOPT_TIMEOUT, 20);
            curl_setopt($curl, CURLOPT_ENCODING, '');
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); // no echo, just return result
            if (!ini_get('open_basedir')) {
                curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true); // sometime is useful :)
            }
            $result = curl_exec($curl);
            return curl_errno($curl) === 0 && curl_getinfo($curl, CURLINFO_HTTP_CODE) === 200
                ? $result
                : false;

        } else {
            $context = null;
            if ($user !== null && $pass !== null) {
                $options = [
                    'http' => [
                        'method' => 'GET',
                        'header' => 'Authorization: Basic ' . base64_encode($user . ':' . $pass) . "\r\n",
                    ],
                ];
                $context = stream_context_create($options);
            }

            return file_get_contents($url, false, $context);
        }
    }


    /**
     * Generates better accessible namespaced tags.
     * @param  SimpleXMLElement
     * @return void
     */
    private static function adjustNamespaces($el)
    {
        foreach ($el->getNamespaces(true) as $prefix => $ns) {
            $children = $el->children($ns);
            foreach ($children as $tag => $content) {
                $el->{$prefix . ':' . $tag} = $content;
            }
        }
    }
}



/**
 * An exception generated by Feed.
 */
class FeedException extends Exception
{
}



$_SESSION['PAGE'] = 'notifications';

// Check http://www.systutorials.com/136102/a-php-function-for-fetching-rss-feed-and-outputing-feed-items-as-html/ for description

// RSS to HTML
/*
    $tiem_cnt: max number of feed items to be displayed
    $max_words: max number of words (not real words, HTML words)
    if <= 0: no limitation, if > 0 display at most $max_words words
 */
function get_rss_feed_as_html($feed_url, $max_item_cnt = 10, $show_date = true, $show_description = true, $max_words = 0, $cache_timeout = 7200, $cache_prefix = "/tmp/rss2html-")
{
    $result = "";
    // get feeds and parse items
    $rss = new DOMDocument();
    $cache_file = $cache_prefix . md5($feed_url);
    // load from file or load content
    if ($cache_timeout > 0 &&
        is_file($cache_file) &&
        (filemtime($cache_file) + $cache_timeout > time())) {
            $rss->load($cache_file);
    } else {
        $rss->load($feed_url);
        if ($cache_timeout > 0) {
            $rss->save($cache_file);
        }
    }
    $feed = array();
    foreach ($rss->getElementsByTagName('item') as $node) {
        $item = array (
            'title' => $node->getElementsByTagName('title')->item(0)->nodeValue,
            'desc' => $node->getElementsByTagName('description')->item(0)->nodeValue,
            'content' => $node->getElementsByTagName('description')->item(0)->nodeValue,
            'link' => $node->getElementsByTagName('link')->item(0)->nodeValue,
            'date' => $node->getElementsByTagName('pubDate')->item(0)->nodeValue,
        );
        $content = $node->getElementsByTagName('encoded'); // <content:encoded>
        if ($content->length > 0) {
            $item['content'] = $content->item(0)->nodeValue;
        }
        array_push($feed, $item);
    }
    // real good count
    if ($max_item_cnt > count($feed)) {
        $max_item_cnt = count($feed);
    }
    $result .= '<ul class="feed-lists">';
    for ($x=0;$x<$max_item_cnt;$x++) {
        $title = str_replace(' & ', ' &amp; ', $feed[$x]['title']);
        $link = $feed[$x]['link'];
        $result .= '<li class="feed-item">';
        $result .= '<div class="feed-title"><strong><a href="'.$link.'" title="'.$title.'">'.$title.'</a></strong></div>';
        if ($show_date) {
            $date = date('l F d, Y', strtotime($feed[$x]['date']));
            $result .= '<small class="feed-date"><em>Posted on '.$date.'</em></small>';
        }
        if ($show_description) {
            $description = $feed[$x]['desc'];
            $content = $feed[$x]['content'];
            // find the img
            $has_image = preg_match('/<img.+src=[\'"](?P<src>.+?)[\'"].*>/i', $content, $image);
            // no html tags
            $description = strip_tags(preg_replace('/(<(script|style)\b[^>]*>).*?(<\/\2>)/s', "$1$3", $description), '');
            // whether cut by number of words
            if ($max_words > 0) {
                $arr = explode(' ', $description);
                if ($max_words < count($arr)) {
                    $description = '';
                    $w_cnt = 0;
                    foreach($arr as $w) {
                        $description .= $w . ' ';
                        $w_cnt = $w_cnt + 1;
                        if ($w_cnt == $max_words) {
                            break;
                        }
                    }
                    $description .= " ...";
                }
            }
            // add img if it exists
            if ($has_image == 1) {
                $description = '<img class="feed-item-image" src="' . $image['src'] . '" />' . $description;
            }
            $result .= '<div class="feed-description">' . $description;
            $result .= ' <a href="'.$link.'" title="'.$title.'">Continue Reading &raquo;</a>'.'</div>';
        }
        $result .= '</li>';
    }
    $result .= '</ul>';
    return $result;
}

function output_rss_feed($feed_url, $max_item_cnt = 10, $show_date = true, $show_description = true, $max_words = 0)
{
    echo get_rss_feed_as_html($feed_url, $max_item_cnt, $show_date, $show_description, $max_words);
}

?>

<div class="hide-to-fade" id="notifications">
	<div class="row no-gutters">
		<div class="col-md-6 valheim-news">
			<h1>Offical Valheim News</h1>
			<?php
			// output RSS feed to HTML
			output_rss_feed('https://store.steampowered.com/feeds/news/app/892970/?cc=US&l=english&snr=1_2108_9__2107', 30, true, true, 30);
			?>
		</div>
		<div class="col-md-6 njordmenu-news">
			<h1>Njord Menu Releases</h1>
			<?php
            $url = 'https://github.com/Nimdy/Dedicated_Valheim_Server_Script/releases.atom';
            $atom = Feed::loadAtom($url);
			?>

            <?php foreach ($atom->entry as $entry): ?>
                <h2><a href="<?php echo htmlspecialchars($entry->url) ?>"><?php echo htmlspecialchars($entry->title) ?></a>
                <small><?php echo date('j.n.Y H:i', (int) $entry->timestamp) ?></small></h2>

                <?php if ($entry->content['type'] == 'html'): ?>
                    <div><?php echo $entry->content ?></div>
                <?php else: ?>
                    <p><?php echo htmlspecialchars($entry->content) ?></p>
                <?php endif ?>
            <?php endforeach ?>
		</div>
	</div>
</div>