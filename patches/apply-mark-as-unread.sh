#!/bin/bash
set -euo pipefail

# Apply "Mark as unread" feature to extracted Codex/Codex-Intel app bundle
# Usage: ./apply-mark-as-unread.sh /path/to/extracted/app/webview/assets

ASSETS_DIR="${1:-/Users/anastasia/workspace_ai/codex-intel/work/install.Gs99wx/app-extract/webview/assets}"

if [ ! -d "$ASSETS_DIR" ]; then
    echo "Error: Assets directory not found: $ASSETS_DIR"
    echo "Usage: $0 /path/to/extracted/app/webview/assets"
    exit 1
fi

echo "Applying 'Mark as unread' patches to $ASSETS_DIR..."

# Patch 1: thread-overflow-menu-CSIaLAFF.js
THREAD_OVERFLOW=$(find "$ASSETS_DIR" -name 'thread-overflow-menu-*.js' | head -1)
if [ -z "$THREAD_OVERFLOW" ]; then
    echo "Error: thread-overflow-menu-*.js not found in $ASSETS_DIR"
    exit 1
fi

echo "Patching $THREAD_OVERFLOW..."

# 1a. Add hasUnreadTurn prop to Vt component signature and destructure markThreadAsUnread/markThreadAsRead
sed -i '' 's/,triggerIconClassName:ce}){let S=n(Ee),le=xe()===_e,C=te(),{archiveThread:ue,renameThread:de,copyAppLink:w,copyConversationMarkdown:fe,copySessionId:pe,copyWorkingDirectory:E}=$e(),D=Oe()/,triggerIconClassName:ce,hasUnreadTurn:eT=!1}){let S=n(Ee),le=xe()===_e,C=te(),{archiveThread:ue,renameThread:de,copyAppLink:w,copyConversationMarkdown:fe,copySessionId:pe,copyWorkingDirectory:E,markThreadAsUnread:tu,markThreadAsRead:tr}=$e(),D=Oe()/' "$THREAD_OVERFLOW"

# 1b. Add menu item after archive item, before separator
sed -i '' 's/z.archiveThread})}),(0,\$.jsx)(U.Separator,{})/z.archiveThread})}),e==null?null:(0,\$.jsx)(U.Item,{onSelect:()=>{e!=null&&F!=null&&(eT?tr({conversationId:e,hostId:F}):tu({conversationId:e,hostId:F}))},children:(0,\$.jsx)(v,{...eT?z.markThreadRead:z.markThreadUnread})}),(0,\$.jsx)(U.Separator,{})/' "$THREAD_OVERFLOW"

echo "✓ thread-overflow-menu patched"

# Patch 2: projects-index-page-DGzA85Sh.js
PROJECTS_INDEX=$(find "$ASSETS_DIR" -name 'projects-index-page-*.js' | head -1)
if [ -z "$PROJECTS_INDEX" ]; then
    echo "Error: projects-index-page-*.js not found in $ASSETS_DIR"
    exit 1
fi

echo "Patching $PROJECTS_INDEX..."

# Update Rr function: increase cache size from 6 to 7, add hasUnreadTurn selector, add to cache deps
sed -i '' 's/function Rr(e){let t=(0,Z.c)(6),{entry:n}=e,i=n.conversationId,o=r(Ee,i)??n.summary?.title??null,s=n.cwd,c=n.workspaceKind===`projectless`,l;t\[0\]===Symbol.for(`react.memo_cache_sentinel`)?(l=a(Y,`opacity-0 group-hover\/thread-row:opacity-100 focus-visible:opacity-100 data-\[state=open\]:opacity-100`),t\[0\]=l):l=t\[0\];let u;return t\[1\]!==i\|\|t\[2\]!==n.cwd\|\|t\[3\]!==c\|\|t\[4\]!==o?(u=(0,\$.jsx)(Pn,{archiveNavigation:`none`,archiveSource:`projects_index_thread_overflow_menu`,conversationId:i,cwd:s,dropdownAlign:`end`,hideForkActions:c,title:o,triggerButtonClassName:l,triggerButtonColor:`ghostMuted`,triggerIconClassName:`icon-xs`}),t\[1\]=i,t\[2\]=n.cwd,t\[3\]=c,t\[4\]=o,t\[5\]=u):u=t\[5\],u}/function Rr(e){let t=(0,Z.c)(7),{entry:n}=e,i=n.conversationId,o=r(Ee,i)??n.summary?.title??null,s=n.cwd,c=n.workspaceKind===`projectless`,d=r(Pe,i),l;t\[0\]===Symbol.for(`react.memo_cache_sentinel`)?(l=a(Y,`opacity-0 group-hover\/thread-row:opacity-100 focus-visible:opacity-100 data-\[state=open\]:opacity-100`),t\[0\]=l):l=t\[0\];let u;return t\[1\]!==i\|\|t\[2\]!==n.cwd\|\|t\[3\]!==c\|\|t\[4\]!==o\|\|t\[5\]!==d?(u=(0,\$.jsx)(Pn,{archiveNavigation:`none`,archiveSource:`projects_index_thread_overflow_menu`,conversationId:i,cwd:s,dropdownAlign:`end`,hasUnreadTurn:d,hideForkActions:c,title:o,triggerButtonClassName:l,triggerButtonColor:`ghostMuted`,triggerIconClassName:`icon-xs`}),t\[1\]=i,t\[2\]=n.cwd,t\[3\]=c,t\[4\]=o,t\[5\]=d,t\[6\]=u):u=t\[6\],u/' "$PROJECTS_INDEX"

echo "✓ projects-index-page patched"

echo ""
echo "Done! The 'Mark as unread' feature has been applied."
echo "The blue dot indicator will now appear in the conversation list when you mark a chat as unread."