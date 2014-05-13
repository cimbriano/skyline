'''
Created on Apr 29, 2014

@author: maxp
'''


import argparse
import pandas as pd
import numpy as np
import json

# def freneticity(col):
#     return np.diff(col).mean()

note_keys = {
  -7 : ['B', 'C#', 'D#', 'E', 'F#', 'G#', 'A#'],
  -6 : ['F#', 'G#', 'A#', 'B', 'C#', 'D#', 'F'],
  -5 : ['C#', 'D#', 'F', 'F#', 'G#', 'A#', 'C'],
  -4 : ['G#', 'A#', 'C', 'C#', 'D#', 'F', 'G'],
  -3 : ['D#', 'F', 'G', 'G#', 'A#', 'C', 'D'],
  -2 : ['A#', 'C', 'D', 'D#', 'F', 'G', 'A'],
  -1 : ['F', 'G', 'A', 'A#', 'C', 'D', 'E'],
  0 : ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
  1 : ['G', 'A', 'B', 'C', 'D', 'E', 'F#'],
  2 : ['D', 'E', 'F#', 'G', 'A', 'B', 'C#'],
  3 : ['A', 'B', 'C#', 'D', 'E', 'F#', 'G#'],
  4 : ['E', 'F#', 'G#', 'A', 'B', 'C#', 'D#'],
  5 : ['B', 'C#', 'D#', 'E', 'F#', 'G#', 'A#'],
  6 : ['F#', 'G#', 'A#', 'B', 'C#', 'D#', 'F'],
  7 : ['C#', 'D#', 'F', 'F#', 'G#', 'A#', 'C']
}



def main():
    parser = argparse.ArgumentParser(prog='stats')
    parser.add_argument('note_file',
                        help='full path to the notes file')
    parser.add_argument('stats_file',
                        help='full path to the stats file')
    #not used right now
    parser.add_argument('--mode',default=0, choices=[0,1],
                        help='aggregation mode')
    args = parser.parse_args()

    # cwd =  os.getcwd()
    note_file = args.note_file
    stats_file = args.stats_file
    
    print "Reading notes from: " + note_file
    note_df = pd.read_csv(note_file)

    song_length = (note_df.time_off.max() - note_df.time_on.min()) / 1000.0
    notes_per_sec = len(note_df) / song_length
    total_notes = len(note_df)
    song_avg_len = note_df.duration.mean()
    song_avg_vel = note_df.velocity.mean()
    high_note = note_df.note_number.max()
    low_note = note_df.note_number.min()
    note_range = high_note - low_note

    sumagg_df = note_df.groupby(['letter'])
    sumcnt = sumagg_df.letter.count()
    sumavgLen = sumagg_df.duration.mean()
    sumtotLen = sumagg_df.duration.sum()
    sumtotLenRank = sumagg_df.duration.sum().rank(ascending=True)
    sumavgVel = sumagg_df.velocity.mean()
    sumNotePerSec = (sumcnt * 1000.0)/(sumagg_df.time_off.max()-sumagg_df.time_on.min())
    sumOctCount = sumagg_df.octave.nunique()
    sumOctRange = sumagg_df.octave.max()-sumagg_df.octave.min() + 1

    sumcnt.name = 'count'
    sumavgLen.name = 'avgLen'
    sumtotLen.name = 'totLen'
    sumtotLenRank.name = 'totLenRank'
    sumavgVel.name = 'avgVel'
    sumNotePerSec.name = 'notes_per_sec'
    sumOctCount.name = 'octave_count'
    sumOctRange.name = 'octave_range'

    agg_df = note_df.groupby(['letter','octave'])
    cnt = agg_df.letter.count()
    avgLen = agg_df.duration.mean()
    totLen = agg_df.duration.sum()
    avgVel = agg_df.velocity.mean()
    notePerSec = (cnt*1000.0)/(agg_df.time_off.max()-agg_df.time_on.min())
    # timeBtwn = agg_df.time_on.apply(freneticity)
    # timeBtwn.fillna(0, inplace=True)

    
    cnt.name = 'count'
    avgLen.name = 'avgLen'
    totLen.name = 'totLen'
    avgVel.name = 'avgVel'
    notePerSec.name = 'notes_per_sec'
    # timeBtwn.name = 'timeBetween'
    
    ans  = pd.concat([cnt, avgVel, avgLen, totLen, notePerSec], axis=1)
    sumans  = pd.concat([sumcnt, sumavgVel, sumavgLen, sumtotLen, sumtotLenRank, sumNotePerSec, sumOctRange, sumOctCount], axis=1)
    songans = {'length' : song_length, 'notes_per_sec':notes_per_sec, 'total_notes':total_notes, 
               'avgLen':song_avg_len, 'avgVel':song_avg_vel, 'high_note':high_note, 'low_note':low_note,'note_range':note_range}
    ansdict = {'song':{}, 'instruments':{},'notes':{}}

    for (letter,octave), r in ans.iterrows():
        if not ansdict['notes'].has_key(letter): 
            ansdict['notes'][letter] = {'octaves': {}}
        ansdict['notes'][letter]['octaves'][octave] = r.to_dict()
    
    for letter, row in sumans.iterrows():
        ansdict['notes'][letter]['summary'] = row.to_dict()
    ansdict['song']['summary'] = songans

    with open(stats_file, 'w') as stats_json:
        print "Writing json to: " + stats_file
        json.dump(ansdict, stats_json)

if __name__ == '__main__':
    main()