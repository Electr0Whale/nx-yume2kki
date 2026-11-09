#!/usr/bin/env python3
"""
Patch Nintendo Switch control.nacp for Yume 2kki:
- Title ID: 0x0100B2B2C3D40000
- StartupUserAccount = 1 (Required: HOS prompts user selector on launch)
- SaveDataOwnerId = 0x0100B2B2C3D40000
- UserAccountSaveDataSize = 16 MiB (0x01000000)
- UserAccountSaveDataJournalSize = 16 MiB (0x01000000)
- UserAccountSaveDataSizeMax = 32 MiB (0x02000000)
- UserAccountSaveDataJournalSizeMax = 32 MiB (0x02000000)
- 16-language localized titles and publishers for Switch Home Menu
"""

import struct
import sys

TITLE_ID = 0x0100B2B2C3D40000
SAVE_SIZE = 16 * 1024 * 1024      # 16 MiB
JOURNAL_SIZE = 16 * 1024 * 1024   # 16 MiB
SAVE_MAX = 32 * 1024 * 1024       # 32 MiB
JOURNAL_MAX = 32 * 1024 * 1024    # 32 MiB

# Localized titles for Switch Home Menu (16 standard HOS languages)
TITLES = {
    0: ("Yume 2kki", "Yume 2kki Developers"),        # AmericanEnglish
    1: ("Yume 2kki", "Yume 2kki Developers"),        # BritishEnglish
    2: ("ゆめ2っき", "ゆめ2っき制作者有志"),             # Japanese
    3: ("Yume 2kki", "Yume 2kki Developers"),        # French
    4: ("Yume 2kki", "Yume 2kki Developers"),        # German
    5: ("Yume 2kki", "Yume 2kki Developers"),        # LatinAmericanSpanish
    6: ("Yume 2kki", "Yume 2kki Developers"),        # Spanish
    7: ("Yume 2kki", "Yume 2kki Developers"),        # Italian
    8: ("Yume 2kki", "Yume 2kki Developers"),        # Dutch
    9: ("Yume 2kki", "Yume 2kki Developers"),        # CanadianFrench
    10: ("Yume 2kki", "Yume 2kki Developers"),       # Portuguese
    11: ("Yume 2kki", "Yume 2kki Developers"),       # Russian
    12: ("유메2키", "유메2키 제작진"),                 # Korean
    13: ("夢２記", "夢2記製作組"),                    # TraditionalChinese
    14: ("梦２记", "梦2记制作组"),                    # SimplifiedChinese
    15: ("Yume 2kki", "Yume 2kki Developers"),       # BrazilianPortuguese
}


def patch_nacp(path: str) -> None:
    with open(path, "rb") as f:
        data = bytearray(f.read())

    if len(data) != 0x4000:
        raise ValueError(f"Unexpected control.nacp size: {len(data)} (expected 0x4000)")

    # StartupUserAccount: 1 = Required (prompts HOS user selector at launch)
    data[0x3025] = 1

    # SaveDataOwnerId
    struct.pack_into("<Q", data, 0x3078, TITLE_ID)

    # UserAccountSaveDataSize & UserAccountSaveDataJournalSize
    struct.pack_into("<Q", data, 0x3080, SAVE_SIZE)
    struct.pack_into("<Q", data, 0x3088, JOURNAL_SIZE)

    # UserAccountSaveDataSizeMax & UserAccountSaveDataJournalSizeMax
    struct.pack_into("<Q", data, 0x3148, SAVE_MAX)
    struct.pack_into("<Q", data, 0x3150, JOURNAL_MAX)

    for idx, (title, author) in TITLES.items():
        base = idx * 0x300
        # clear entry
        data[base:base + 0x300] = b"\x00" * 0x300
        title_bytes = title.encode("utf-8")[:0x1FF]
        author_bytes = author.encode("utf-8")[:0xFF]
        data[base:base + len(title_bytes)] = title_bytes
        data[base + 0x200:base + 0x200 + len(author_bytes)] = author_bytes

    with open(path, "wb") as f:
        f.write(data)

    print(f"Patched {path} for Yume 2kki:")
    print(f"  StartupUserAccount (0x3025)            = {data[0x3025]}")
    print(f"  SaveDataOwnerId (0x3078)               = 0x{struct.unpack_from('<Q', data, 0x3078)[0]:016X}")
    print(f"  UserAccountSaveDataSize (0x3080)       = 0x{struct.unpack_from('<Q', data, 0x3080)[0]:08X} ({SAVE_SIZE // (1024 * 1024)} MiB)")
    print(f"  UserAccountSaveDataJournalSize (0x3088)= 0x{struct.unpack_from('<Q', data, 0x3088)[0]:08X} ({JOURNAL_SIZE // (1024 * 1024)} MiB)")
    print(f"  UserAccountSaveDataSizeMax (0x3148)    = 0x{struct.unpack_from('<Q', data, 0x3148)[0]:08X} ({SAVE_MAX // (1024 * 1024)} MiB)")
    print(f"  UserAccountSaveDataJournalMax (0x3150) = 0x{struct.unpack_from('<Q', data, 0x3150)[0]:08X} ({JOURNAL_MAX // (1024 * 1024)} MiB)")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path/to/control.nacp>", file=sys.stderr)
        sys.exit(1)
    patch_nacp(sys.argv[1])
