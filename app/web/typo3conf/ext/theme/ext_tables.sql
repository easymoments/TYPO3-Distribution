CREATE TABLE tt_content (
  bodytext_1 text,
  bodytext_2 text
);

CREATE TABLE pages (
  tx_theme_sharing_enabled int(11) unsigned DEFAULT '1',
  tx_theme_opengraph_image int(11) unsigned DEFAULT '0' NOT NULL
);
