# (c) 2019 Copyright, Real-Time Innovations, Inc. All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or revisions thereof,
# must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.
FROM python:3.7.2-alpine3.7
RUN adduser -D myuser
USER myuser
WORKDIR /artifacts
CMD ["python", "-m", "http.server"]