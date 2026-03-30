# SKILL-CASEY-DATAROOM.md — Data Room Management

Use this skill when Casey is asked to upload, save, move, or sync files to the dataroom, or to sync from Google Drive.

## Trigger Phrase

- `casey upload to dataroom`
- `casey save to dataroom`
- `casey store in dataroom`
- `upload to dataroom`
- `casey sync dataroom`
- `casey sync`
- Any message addressed to Casey that includes a file and asks to upload or save it to the dataroom

## Data Room Path

`/home/azlan/dataroom/`

## Working Procedure

1. The incoming message will include a `MediaPath` pointing to the downloaded file in `/home/azlan/.openclaw/media/inbound/`.
2. Use the `MediaFileName` from the message context as the destination filename. If no filename is available, derive a sensible name from the file type and current date.
3. Use the filesystem MCP to copy the file from `MediaPath` to `/home/azlan/dataroom/<filename>`.
4. Confirm the file is saved by listing `/home/azlan/dataroom/` after the copy.
5. Reply with the filename and full destination path.

## If Multiple Files

- If the user sends multiple files in sequence and says "upload to dataroom" for each, process each one.
- If the user sends one file and says "upload these to dataroom", wait — ask if there are more files coming before confirming.

## Success Response Format

```
Saved to dataroom:
File: <filename>
Path: /home/azlan/dataroom/<filename>
```

## Google Drive Sync

When asked to sync the dataroom, run the sync script:

```
/home/azlan/dataroom/sync-gdrive.sh
```

This syncs `Greenviro_Mutiara_Drive` from Google Drive into `/home/azlan/dataroom/Greenviro_Mutiara_Drive/`.

After sync completes, confirm what was synced by listing the folder contents.

If the user says "sync and analyse" or "sync then run diligence" — sync first, wait for completion, then immediately apply the document digestion protocol from `SKILL-CASEY-MNA.md` on the contents of `/home/azlan/dataroom/Greenviro_Mutiara_Drive/`.

Sync log is at `/home/azlan/dataroom/sync.log`.

## Notes

- Do not rename files unless the user asks.
- Do not delete the original from the inbound folder.
- If a file with the same name already exists in dataroom, append the date-time to avoid overwriting: `<filename>-20260329T1724.pdf`.
