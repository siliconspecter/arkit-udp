# ARKit UDP

iOS application to forward face tracking data from ARKit via UDP.

## Dependencies

- Xcode 16.2.
- iOS 18.5.

## Usage

This application, once built, will present a GUI for selecting a recipient IP
address and port.  When both face tracking and the UDP conneciton are both
enabled, all detected faces will be forwarded as follows:

| Byte | Description                                                                                                                                                                                      |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 128  | Length of command.                                                                                                                                                                               |
| 0    |                                                                                                                                                                                                  |
| 0    |                                                                                                                                                                                                  |
| 0    |                                                                                                                                                                                                  |
| 1    | Magic number.                                                                                                                                                                                    |
| 0    |                                                                                                                                                                                                  |
| 0    |                                                                                                                                                                                                  |
| 0    |                                                                                                                                                                                                  |
| 220  | Unique identifier for the face; should for example, two faces be seen at once, each receives its own ID.  If tracking is briefly lost for a face, when it is found again, it will have a new ID. |
| 31   |                                                                                                                                                                                                  |
| 223  |                                                                                                                                                                                                  |
| 22   |                                                                                                                                                                                                  |
| 29   |                                                                                                                                                                                                  |
| 29   |                                                                                                                                                                                                  |
| 114  |                                                                                                                                                                                                  |
| 240  |                                                                                                                                                                                                  |
| 25   |                                                                                                                                                                                                  |
| 128  |                                                                                                                                                                                                  |
| 170  |                                                                                                                                                                                                  |
| 231  |                                                                                                                                                                                                  |
| 243  |                                                                                                                                                                                                  |
| 161  |                                                                                                                                                                                                  |
| 173  |                                                                                                                                                                                                  |
| 170  |                                                                                                                                                                                                  |
| 172  | X axis of the face's location.                                                                                                                                                                   |
| 15   |                                                                                                                                                                                                  |
| 91   |                                                                                                                                                                                                  |
| 34   |                                                                                                                                                                                                  |
| 151  | Y axis of the face's location.                                                                                                                                                                   |
| 148  |                                                                                                                                                                                                  |
| 255  |                                                                                                                                                                                                  |
| 223  |                                                                                                                                                                                                  |
| 176  | Z axis of the face's location.                                                                                                                                                                   |
| 56   |                                                                                                                                                                                                  |
| 238  |                                                                                                                                                                                                  |
| 181  |                                                                                                                                                                                                  |
| 253  | X axis of the face's forward normal.                                                                                                                                                             |
| 18   |                                                                                                                                                                                                  |
| 98   |                                                                                                                                                                                                  |
| 46   |                                                                                                                                                                                                  |
| 124  | Y axis of the face's forward normal.                                                                                                                                                             |
| 226  |                                                                                                                                                                                                  |
| 23   |                                                                                                                                                                                                  |
| 124  |                                                                                                                                                                                                  |
| 19   | Z axis of the face's forward normal.                                                                                                                                                             |
| 98   |                                                                                                                                                                                                  |
| 114  |                                                                                                                                                                                                  |
| 61   |                                                                                                                                                                                                  |
| 146  | X axis of the face's up normal.                                                                                                                                                                  |
| 117  |                                                                                                                                                                                                  |
| 130  |                                                                                                                                                                                                  |
| 63   |                                                                                                                                                                                                  |
| 46   | Y axis of the face's up normal.                                                                                                                                                                  |
| 87   |                                                                                                                                                                                                  |
| 78   |                                                                                                                                                                                                  |
| 23   |                                                                                                                                                                                                  |
| 71   | Z axis of the face's up normal.                                                                                                                                                                  |
| 113  |                                                                                                                                                                                                  |
| 168  |                                                                                                                                                                                                  |
| 41   |                                                                                                                                                                                                  |
| 212  | 0 = left eye open, 0.25 = left eye closed.                                                                                                                                                       |
| 54   |                                                                                                                                                                                                  |
| 253  |                                                                                                                                                                                                  |
| 116  |                                                                                                                                                                                                  |
| 0    | 0 = right eye open, 0.25 = right eye closed.                                                                                                                                                     |
| 101  |                                                                                                                                                                                                  |
| 220  |                                                                                                                                                                                                  |
| 199  |                                                                                                                                                                                                  |
| 106  | 0 = left eye centered, 0.25 = left eye looking up.                                                                                                                                               |
| 82   |                                                                                                                                                                                                  |
| 59   |                                                                                                                                                                                                  |
| 176  |                                                                                                                                                                                                  |
| 5    | 0 = right eye centered, 0.25 = right eye looking up.                                                                                                                                             |
| 38   |                                                                                                                                                                                                  |
| 148  |                                                                                                                                                                                                  |
| 107  |                                                                                                                                                                                                  |
| 103  | 0 = left eye centered, 0.25 = left eye looking down.                                                                                                                                             |
| 91   |                                                                                                                                                                                                  |
| 27   |                                                                                                                                                                                                  |
| 145  |                                                                                                                                                                                                  |
| 164  | 0 = right eye centered, 0.25 = right eye looking down.                                                                                                                                           |
| 189  |                                                                                                                                                                                                  |
| 181  |                                                                                                                                                                                                  |
| 246  |                                                                                                                                                                                                  |
| 54   | 0 = left eye centered, 0.6 = left eye looking left.                                                                                                                                              |
| 225  |                                                                                                                                                                                                  |
| 106  |                                                                                                                                                                                                  |
| 236  |                                                                                                                                                                                                  |
| 108  | 0 = right eye centered, 0.6 = right eye looking left.                                                                                                                                            |
| 64   |                                                                                                                                                                                                  |
| 219  |                                                                                                                                                                                                  |
| 208  |                                                                                                                                                                                                  |
| 114  | 0 = left eye centered, 0.6 = left eye looking right.                                                                                                                                             |
| 226  |                                                                                                                                                                                                  |
| 60   |                                                                                                                                                                                                  |
| 169  |                                                                                                                                                                                                  |
| 206  | 0 = right eye centered, 0.6 = right eye looking right.                                                                                                                                           |
| 151  |                                                                                                                                                                                                  |
| 74   |                                                                                                                                                                                                  |
| 59   |                                                                                                                                                                                                  |
| 143  | 0 = left eye relaxed, 0.6 = left eye wide.                                                                                                                                                       |
| 162  |                                                                                                                                                                                                  |
| 21   |                                                                                                                                                                                                  |
| 214  |                                                                                                                                                                                                  |
| 159  | 0 = right eye relaxed, 0.6 = right eye wide.                                                                                                                                                     |
| 115  |                                                                                                                                                                                                  |
| 55   |                                                                                                                                                                                                  |
| 120  |                                                                                                                                                                                                  |
| 35   | 0 = neutral, 0.6 = left smile.                                                                                                                                                                   |
| 47   |                                                                                                                                                                                                  |
| 230  |                                                                                                                                                                                                  |
| 0    |                                                                                                                                                                                                  |
| 92   | 0 = neutral, 0.6 = right smile.                                                                                                                                                                  |
| 48   |                                                                                                                                                                                                  |
| 193  |                                                                                                                                                                                                  |
| 95   |                                                                                                                                                                                                  |
| 55   | 0 = neutral, 0.55 = o/u mouth shape.                                                                                                                                                             |
| 78   |                                                                                                                                                                                                  |
| 28   |                                                                                                                                                                                                  |
| 215  |                                                                                                                                                                                                  |
| 16   | 0 = neutral, 0.55 = left frown.                                                                                                                                                                  |
| 160  |                                                                                                                                                                                                  |
| 141  |                                                                                                                                                                                                  |
| 254  |                                                                                                                                                                                                  |
| 16   | 0 = neutral, 0.55 = right frown.                                                                                                                                                                  |
| 160  |                                                                                                                                                                                                  |
| 141  |                                                                                                                                                                                                  |
| 254  |                                                                                                                                                                                                  |
| 90   | 0 = neutral, 1 = mouth open or jaw lowered.                                                                                                                                                      |
| 70   |                                                                                                                                                                                                  |
| 175  |                                                                                                                                                                                                  |
| 46   |                                                                                                                                                                                                  |
