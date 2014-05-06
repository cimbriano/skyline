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
    sumavgVel = sumagg_df.velocity.mean()
    sumfreq = (sumcnt * 1000.0)/(sumagg_df.time_off.max()-sumagg_df.time_on.min())
    sumOctCount = sumagg_df.octave.nunique()
    sumOctRange = sumagg_df.octave.max()-sumagg_df.octave.min()

    sumcnt.name = 'count'
    sumavgLen.name = 'avgLen'
    sumavgVel.name = 'avgVelocity'
    sumfreq.name = 'frequency'
    sumOctCount.name = 'octave_count'
    sumOctRange.name = 'octave_range'

    agg_df = note_df.groupby(['letter','octave'])
    cnt = agg_df.letter.count()
    avgLen = agg_df.duration.mean()
    avgVel = agg_df.velocity.mean()
    freq = (cnt*1000.0)/(agg_df.time_off.max()-agg_df.time_on.min())
    # timeBtwn = agg_df.time_on.apply(freneticity)
    # timeBtwn.fillna(0, inplace=True)

    
    cnt.name = 'count'
    avgLen.name = 'avgLen'
    avgVel.name = 'avgVelocity'
    freq.name = 'frequency'
    # timeBtwn.name = 'timeBetween'
    
    ans  = pd.concat([cnt, avgVel, avgLen, freq], axis=1)
    sumans  = pd.concat([sumcnt, sumavgVel, sumavgLen, sumfreq, sumOctRange, sumOctCount], axis=1)
    songans = {'length' : song_length, 'notes_per_sec':notes_per_sec, 'total_notes':total_notes, 
               'avgLen':song_avg_len, 'avgVel':song_avg_vel, 'high_note':high_note, 'low_note':low_note,'note_range':note_range}
    ansdict = {}

    for (letter,octave), r in ans.iterrows():
        if not ansdict.has_key(letter): 
            ansdict[letter] = {}
        ansdict[letter][octave] = r.to_dict()
    
    for letter, row in sumans.iterrows():
        ansdict[letter]['summary'] = row.to_dict()
    ansdict['summary'] = songans

    with open(stats_file, 'w') as stats_json:
        print "printing " + stats_file

        json.dump(ansdict, stats_json)


if __name__ == '__main__':
    main()