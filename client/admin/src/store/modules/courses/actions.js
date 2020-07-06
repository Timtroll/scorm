import coursesClass from './../../../api/courses'

const courses = new coursesClass

const actions = {

  async getLevel ({commit, state}, parent) {
    try {
      const response = await courses.load(parent)
      console.log(response)
    }
    catch (e) {
      notify('ERROR: ' + e, 'danger')
      throw 'ERROR: ' + e
    }
  }

}
export default actions
