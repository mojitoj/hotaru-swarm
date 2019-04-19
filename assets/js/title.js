import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

const styles = {
  card: {
    minWidth: 275,
  },
  bullet: {
    display: 'inline-block',
    margin: '0 2px',
    transform: 'scale(0.8)',
  },
  title: {
    fontSize: 14,
  },
  pos: {
    marginBottom: 12,
  },
};

function SimpleCard(props) {
  const { classes } = props;
  const bull = <span className={classes.bullet}>•</span>;

  return (
    <Card className={classes.card}>
      <CardContent>
        <Typography variant="h3" component="h2">
          Hotaru Swarm
        </Typography>

        <Typography variant="h7" component="p">
          Hotaru Swarm is an experimental implementation of the emerging FHIR Bulk Data Transfer specifications 
          written in Elixir and Phoenix.<br/>
        </Typography>
        <CardActions>
          <Button size="large" href="https://github.com/mojitoholic/hotaru-swarm" className={classes.button}>
            Source Code 
          </Button>
          <Button size="large" href="https://build.fhir.org/ig/HL7/bulk-data/" className={classes.button}>
            FHIR Bulk Data Transfer Page
          </Button>
          <Button size="large" href="https://github.com/smart-on-fhir/fhir-bulk-data-docs/blob/master/export.md" className={classes.button}>
            Draft Specs
          </Button>
        </CardActions>
      </CardContent>
    </Card>
  );
}

SimpleCard.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(SimpleCard);
