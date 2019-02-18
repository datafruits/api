import Controller from '@ember/controller';
import { inject as service } from '@ember/service';

export default Controller.extend({
  currentPlaylist: service(),
  isSaving: false,
  mixcloudDialog: false,
  soundcloudDialog: false,
  embedDialog: false,
  actions: {
    selectScheduledShow(scheduledShow){
      this.set('model.track.scheduledShow', scheduledShow);
    },
    save(){
      this.set('isSaving', true);
      let track = this.model.track;
      let currentPlaylist = this.get('currentPlaylist.playlist');
      const onSuccess = () =>{
        this.set('isEditing', false);
        this.set('isSaving', false);
        this.transitionToRoute('playlists.show', currentPlaylist.id);
      };
      const onFail = () => {
        console.log("track save failed");
        get(this, 'flashMessages').danger('Something went wrong!');
        this.set('isSaving', false);
      };
      track.save().then(onSuccess, onFail);
    },
    destroy(){
      if(confirm("Are you sure you want to delete this track?")){
        let track = this.model.track;
        // FIXME does this get removed from the playlist as well?
        track.destroyRecord();
      }
    },
    soundcloud(){
      this.set('isEditing', false);
      this.toggleProperty('soundcloudDialog');
    },
    mixcloud(){
      this.set('isEditing', false);
      this.toggleProperty('mixcloudDialog');
    },
    embed(){
      this.set('isEditing', false);
      this.toggleProperty('embedDialog');
    },
  }
});
