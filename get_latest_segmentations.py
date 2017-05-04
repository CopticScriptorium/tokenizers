import requests, re, sys
from collections import defaultdict

def escape(query):
	query = query.replace("&","%26").replace(" ","%20").replace("#","%23")
	return query

def tabulate(xml, counts):
	lines = xml.replace("\r","").replace("><",">\n<").split("\n")
	entries = []
	first = True
	group = ""
	segs = []
	count = 0
	for line in lines:
		if "<entry>" in line:
			first = True
			segs = []
		if "<tupel>" in line and first:
			m = re.search(r'>([^<]*)<',line)
			group = m.group(1)
			first = False
		elif "<tupel>" in line:
			m = re.search(r'>([^<]*)<', line)
			segs.append(m.group(1))
		elif "<count>" in line:
			m = re.search(r'>([^<]*)<', line)
			count = int(m.group(1))
		elif "</entry>" in line:
			if len(group) > 1 and len("|".join(segs)) > 0:
				counts[group]["|".join(segs)] += count
				group = ""
				segs = []
				#entries.append(group + "\t" + "|".join(segs) + "\t" + count)

	return counts

corpora = ["shenoute.eagerness","shenoute.fox", "shenoute.a22", "shenoute.abraham.our.father","apophthegmata.patrum",
		   "besa.letters", "sahidica.mark", "sahidica.1corinthians","doc.papyri"]

sys.stderr.write("o Retrieving segmentations from corpora:\n" + "\n - ".join(sorted(corpora)) + "\n")

corpora = "corpora=" + ",".join(corpora)

queries = []
queries.append("q=norm_group _=_ norm")
queries.append("q=norm_group _l_ norm . norm & #1 _r_ #3")
queries.append("q=norm_group _l_ norm . norm . norm & #1 _r_ #4")
queries.append("q=norm_group _l_ norm . norm . norm . norm & #1 _r_ #5")
queries.append("q=norm_group _l_ norm . norm . norm . norm . norm & #1 _r_ #6")
queries.append("q=norm_group _l_ norm . norm . norm . norm . norm . norm & #1 _r_ #7")
queries.append("q=norm_group _l_ norm . norm . norm . norm . norm . norm . norm & #1 _r_ #8")
queries.append("q=norm_group _l_ norm . norm . norm . norm . norm . norm . norm . norm & #1 _r_ #9")
queries.append("q=norm_group _l_ norm . norm . norm . norm . norm . norm . norm . norm . norm & #1 _r_ #10")

fields = []
fields.append("fields=1:norm_group,2:norm")
fields.append("fields=1:norm_group,2:norm,3:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm,6:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm,6:norm,7:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm,6:norm,7:norm,8:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm,6:norm,7:norm,8:norm,9:norm")
fields.append("fields=1:norm_group,2:norm,3:norm,4:norm,5:norm,6:norm,7:norm,8:norm,9:norm,10:norm")

counts = defaultdict(lambda: defaultdict(int))
params = ""
output = ""
for index, query in enumerate(queries):
	sys.stderr.write("o Getting "+ str(index+1) + " part segmentations...\n")
	field = fields[index]
	query = escape(query)
	params = "&".join([corpora,query,field])

	api_call = "https://corpling.uis.georgetown.edu/annis-service/annis/query/search/frequency?"
	api_call += params
	resp = requests.get(api_call)
	text_content = resp.text
	counts = tabulate(text_content,counts)

for group in counts:
	max_count = 0
	selected = ""
	if len(counts[group])>1:
		pass
	for segs in counts[group]:
		if counts[group][segs] > max_count or (counts[group][segs] == max_count and segs.count("|") > selected.count("|")):  # Prefer more pipes on tie
			selected = segs
			max_count = counts[group][segs]
	output += group + "\t" + selected + "\n"

print output.encode("utf8"),

