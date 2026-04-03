#!/bin/bash 
# ==============================================
# Mars Innovation Labs — LibreChat index.html patcher
# Run after container start or image update
# ==============================================

CONTAINER=${1:-librechat}
TARGET=/app/client/dist/index.html

echo "Patching $CONTAINER:$TARGET ..."

# 1. Description meta
docker exec "$CONTAINER" sed -i \
  's|<meta name="description" content=".*"/>|<meta name="description" content="Powered by Mars Innovation Labs" />|' \
  "$TARGET"

# 2. OG tags (insert after theme-color if missing, or replace if present)
docker exec "$CONTAINER" sed -i \
  's|<meta name="theme-color" content=".*"/>|<meta name="theme-color" content="#171717" />|' \
  "$TARGET"

# 3. Title
docker exec "$CONTAINER" sed -i \
  's|<title>.*</title>|<title>Mars Innovation Labs</title>|' \
  "$TARGET"

# 4. Favicon 32x32
docker exec "$CONTAINER" sed -i \
  's|<link rel="icon" type="image/png" sizes="32x32" href=".*"/>|<link rel="icon" type="image/png" sizes="32x32" href="assets/favicon-32x32.png" />|' \
  "$TARGET"

# 5. Favicon 16x16
docker exec "$CONTAINER" sed -i \
  's|<link rel="icon" type="image/png" sizes="16x16" href=".*"/>|<link rel="icon" type="image/png" sizes="16x16" href="assets/favicon-16x16.png" />|' \
  "$TARGET"

# 6. Apple touch icon
docker exec "$CONTAINER" sed -i \
  's|<link rel="apple-touch-icon" href=".*"/>|<link rel="apple-touch-icon" href="assets/apple-touch-icon-180x180.png" />|' \
  "$TARGET"

# 7. Inject OG block after </title> if not present
docker exec "$CONTAINER" sh -c "
  grep -q 'og:type' $TARGET || sed -i 's|</title>|</title>
    <meta property=\"og:type\" content=\"website\" />
    <meta property=\"og:url\" content=\"https://ai.marsinnolabs.com/\" />
    <meta property=\"og:title\" content=\"Mars Innovation Labs\" />
    <meta property=\"og:site_name\" content=\"Mars Innovation Labs\" />
    <meta property=\"og:description\" content=\"AI-powered financial analytics and business intelligence\" />
    <meta property=\"og:image\" content=\"https://ai.marsinnolabs.com/assets/og-preview.png\" />
    <meta property=\"og:image:width\" content=\"1200\" />
    <meta property=\"og:image:height\" content=\"630\" />
    <meta property=\"og:image:type\" content=\"image/png\" />|' $TARGET
"

echo "Done. Verify with: docker exec $CONTAINER cat $TARGET | grep -E 'title|og:|favicon'"