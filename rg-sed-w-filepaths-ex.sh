rg -l --path-separator // "\.\.\\\\\.\.\\\\\.\.\\\\packages" PATH_HERE | xargs sed -i -E -E 's/\.\.\\(\.\.\\\.\.\\)(packages)/\1\2/g'