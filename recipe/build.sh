#!/usr/bin/env bash
set -euxo pipefail

# Only the Fr command-line tools: the library itself is conda-forge's
# libframel of the same version (in host), so link them against that
# instead of building a second libframel. Same tool list as Fr's
# src/CMakeLists.txt. -std=gnu17: the Fr sources predate C23, where "()"
# in a declarator means "no arguments".
mkdir -p "${PREFIX}/bin"
for app in FrChannels FrCheck FrCopy FrDiff FrDump FrTrend FrameDataDump; do
    ${CC} ${CFLAGS} -std=gnu17 ${CPPFLAGS} -I"${PREFIX}/include" \
        "src/${app}.c" -o "${PREFIX}/bin/${app}" \
        ${LDFLAGS} -L"${PREFIX}/lib" -lframel -lm
done

# the format and library documentation, as Fr's own install puts it
mkdir -p "${PREFIX}/share/doc/framel"
cp doc/*.pdf "${PREFIX}/share/doc/framel/"
